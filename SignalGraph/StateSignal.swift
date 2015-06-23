//
//  Signal.swift
//  SG2
//
//  Created by Hoon H. on 2015/06/20.
//  Copyright © 2015 Eonil. All rights reserved.
//






public protocol StateDefinitionType {
	typealias	Snapshot
	typealias	Transaction
}

public protocol StateStorageType: class {
	typealias	Definition	:	StateDefinitionType
	
	var snapshot: Definition.Snapshot { get }
}

protocol TransactionApplicable {
	typealias	Definition	:	StateDefinitionType
	mutating func apply(transaction: Definition.Transaction)
}




///	A signal to represent mutating state over time.
///
///
///
///	Signal Lifecycle
///	----------------
///
///	These signals will be sent when you registered a monitor to a storage.
///
///	1.	DidInitiate
///	2.	DidBegin
///
///	These signals will be sent for each state update.
///
///	3.	WillEnd
///
///		(state in storage will be updated at this point)
///
///	4.	DidBegin
///
///	Above two signals (3,4) will be triggered by one transaction.
///	That means you will get same transaction parameter value from all four 
///	signals.
///
///	These signals will be sent when you deregister a monitor from a storage.
///
///	5.	WillEnd
///	6.	WillTerminate
///
///
///
///	Usage
///	-----
///
///	You can track state beginning and ending by handling `DidBegin/WillEnd`
///	signals. As you see above list, it will handle everything automatically.
///	Usually, tracking begin/end signals is enough for most simple state cases.
///
///	You don't have to handle `DidInitiate/WillTerminate` signals unless you
///	need to perform some initialization or deinitialization explicitly.
///
///	`DidBegin/WillEnd` signal pair passes `by` parameter that shows you why
///	the state changes. You can check this parameter to select specific 
///	signals. For example, if you want to filter only signals by actual state
///	mutation, then select signals with only
///	`StateSessionNotificationReason.StateMutation` reason.
///
///
///
public enum StateSignal<D: StateDefinitionType>: StateDefinitionType {
	public typealias	Snapshot	=	D.Snapshot
	public typealias	Transaction	=	D.Transaction
	case DidInitiate
//	case WillApply(transaction: Transaction)
	case WillEnd(state: ()->Snapshot, by: ()->StateSessionNotificationReason<D>)
	case DidBegin(state: ()->Snapshot, by: ()->StateSessionNotificationReason<D>)
//	case DidApply(transaction: Transaction)
	case WillTerminate
	
	typealias	Reason	=	StateSessionNotificationReason<D>
}
public enum StateSessionNotificationReason<D: StateDefinitionType> {
	case RegisteringSensor(()->SignalSensor<StateSignal<D>>)
	case DeregisteringSensor(()->SignalSensor<StateSignal<D>>)
	case StateMutation(()->D.Transaction)
	
//	var transaction: D.Transaction? {
//		get {
//			switch self {
//				case .StateMutation(by: let tran):	return	tran()
//				default:				return	nil
//			}
//		}
//	}
}




public class StateStorage<D: StateDefinitionType>: SignalChannel<StateSignal<D>>, StateStorageType {
	public typealias	Definition	=	D
	public typealias	Signal		=	StateSignal<D>
	
	public init(_ snapshot: Definition.Snapshot) {
		self.snapshot	=	snapshot
	}
	public var snapshot: Definition.Snapshot

	///
	
	public override func register(sensor: SignalSensor<Signal>) {
		super.register(sensor)
		transfer(.DidInitiate)
		_apply { (inout state: Definition.Snapshot) -> () in
			transfer(Signal.DidBegin(state: {state}, by: {Signal.Reason.RegisteringSensor({sensor})}))
		}
	}
	public override func deregister(sensor: SignalSensor<Signal>) {
		_apply { (inout state: Definition.Snapshot) -> () in
			transfer(Signal.WillEnd(state: {state}, by: {Signal.Reason.DeregisteringSensor({sensor})}))
		}
		transfer(.WillTerminate)
		super.deregister(sensor)
	}
	final func register(monitor: StateMonitor<D>) {
		register(monitor as SignalSensor<Signal>)
	}
	final func deregister(monitor: StateMonitor<D>) {
		deregister(monitor as SignalSensor<Signal>)
	}
	
	///

	///	An ad hoc function to avoid limitation of Swift 1,
	///	You MUST apply same `transaction` to passed state in `ADHOC_process`.
	internal func ADHOC_apply(transaction: Definition.Transaction, ADHOC_process: (inout Definition.Snapshot)->()) {
		let	reason		=	Signal.Reason.StateMutation({transaction})
		transfer(Signal.WillEnd(state: {snapshot}, by: {reason}))
		ADHOC_process(&snapshot)
		transfer(Signal.DidBegin(state: {snapshot}, by: {reason}))
	}
//	internal func apply(transaction: Definition.Transaction) {
//	}
}


public class StateMonitor<D: StateDefinitionType>: SignalSensor<StateSignal<D>> {
	public typealias	Signal				=	StateSignal<D>
	public typealias	Handler				=	()->()
	public typealias	StateSessionNotificationHandler	=	(state: D.Snapshot, by: StateSessionNotificationReason<D>)->()
//	public typealias	TransactionHandler		=	D.Transaction->()
	
	override init() {
		super.init()
	}
	deinit {
	}

	public var	didInitiate	:	Handler?
//	public var	willApply	:	TransactionHandler?
	public var	willEnd		:	StateSessionNotificationHandler?
	public var	didBegin	:	StateSessionNotificationHandler?
//	public var	didApply	:	TransactionHandler?
	public var	willTerminate	:	Handler?
	
	///
	
//	@availability(*,unavailable)
//	override var handler: (Signal->())? {
//		willSet {
//			fatalError("You cannot set `handler` of this sensor.")
//		}
//	}
	
	override func transfer(signal: ()->Signal) {
		super.transfer(signal)
		_route(signal())
	}
	
	///
	
	private func _route(signal: Signal) {
		switch signal {
		case .DidInitiate:					didInitiate?()
//		case .WillApply(let transaction):			willApply?(transaction)
		case .WillEnd(state: let snapshot, by: let reason):	willEnd?(state: snapshot(), by: reason())
		case .DidBegin(state: let snapshot, by: let reason):	didBegin?(state: snapshot(), by: reason())
//		case .DidApply(let transaction):			didApply?(transaction)
		case .WillTerminate:					willTerminate?()
		}
	}
}




















/////	I recommend to use `StateMonitor` class for monitoring signals from this
/////	dispatcher. That provides more convenient monitoring handlers.
/////	Anyway, you still can use `Monitor` class to get raw signal as is.
//public class StateSignalChannel<D: StateDefinition, S: StateStorageType where S.Definition == D>: SignalEmitter<StateSignal<D>> {
//	typealias	Signal	=	StateSignal<D>
//	typealias	Monitor	=	StateSignalMonitor<D>
//	
//	weak var storage: S?
//
//	public override func register(sensor: SignalSensor<Signal>) {
//		assert(storage != nil)
//		
//		super.register(sensor)
//		transfer(.DidInitiate)
//		transfer(Signal.DidBegin(state: storage!.snapshot, by: Signal.Reason.RegisteringSensor(sensor: sensor)))
//	}
//	public override func deregister(sensor: SignalSensor<Signal>) {
//		assert(storage != nil)
//		
//		transfer(Signal.WillEnd(state: storage!.snapshot, by: Signal.Reason.DeregisteringSensor(sensor: sensor)))
//		transfer(.WillTerminate)
//		super.deregister(sensor)
//	}
//	final func register(monitor: StateSignalMonitor<D>) {
//		super.register(monitor)
//	}
//	final func deregister(monitor: StateSignalMonitor<D>) {
//		super.deregister(monitor)
//	}
//}
//
//public class StateSignalMonitor<D: StateDefinition>: SignalSensor<StateSignal<D>> {
//	typealias	Signal			=	StateSignal<D>
//	typealias	Handler			=	()->()
//	typealias	StateSessionHandler	=	(state: D.Snapshot, by: StateSessionReason<D>)->()
//	typealias	TransactionHandler	=	D.Transaction->()
//	
//	override init() {
//		super.init()
//	}
//	deinit {
//	}
//	
//	var	didInitiate	:	Handler?
//	var	willApply	:	TransactionHandler?
//	var	willEnd		:	StateSessionHandler?
//	var	didBegin	:	StateSessionHandler?
//	var	didApply	:	TransactionHandler?
//	var	willTerminate	:	Handler?
//
//	@available(*,unavailable)
//	override var handler: (Signal->())? {
//		willSet {
//			fatalError("You cannot set `handler` of this sensor.")
//		}
//	}
//	
//	override func transfer(signal: Signal) {
//		super.transfer(signal)
//		_route(signal)
//	}
//
//	///
//	
//	private func _route(signal: Signal) {
//		switch signal {
//		case .DidInitiate:						didInitiate?()
//		case .WillApply(let transaction):				willApply?(transaction)
//		case .WillEnd(state: let snapshot, by: let transaction):	willEnd?(state: snapshot, by: transaction)
//		case .DidBegin(state: let snapshot, by: let transaction):	didBegin?(state: snapshot, by: transaction)
//		case .DidApply(let transaction):				didApply?(transaction)
//		case .WillTerminate:						willTerminate?()
//		}
//	}
//}








//
//public protocol StorageType: class {
//	typealias	State
//	var snapshot: State { get set }
//
////	init(_ state: State)
//	
//	///	Type of signal that emitted by this storage.
//	typealias	Signal
//}
//
//class StateDispatcher<S: StorageType> {
//	typealias	M	=	StateMonitor<S>
//	
//	deinit {
//		assert(_monitors.count == 0, "All monitors must be deregistered before this dispatch dies.")
//	}
//	
//	func register(monitor: M) {
//		assert(_monitors.filter({ $0.object === monitor }).count == 0)
//		_monitors.append(_WeakBox(object: monitor))
//		_dispatch(StateSignal.DidInitiate(subsignal))
//	}
//	func deregister(monitor: M) {
//		assert(_monitors.filter({ $0.object === monitor }).count == 1)
//		_dispatch(StateSignal.WillTerminate)
//		_monitors.removeAtIndex(_monitors.indexOf({ $0.object === monitor })!)
//	}
//	
//	func didInitiate(subsignal: S.Signal) {
//
//	}
//	func willApply(subsignal: S.Signal) {
//		_dispatch(StateSignal.WillApply(subsignal))
//	}
//	func didApply(subsignal: S.Signal) {
//		_dispatch(StateSignal.DidApply(subsignal))
//	}
//	
//	///
//	
//	private weak var	_storage	:	S?
//	private var		_monitors	=	[_WeakBox<M>]()
//	
//	private func _dispatch(signal: StateSignal<S.Signal>) {
//		_monitors.map({ $0.object!._apply(signal) })
//	}
//}
//private struct _WeakBox<T: AnyObject> {
//	weak var object: T?
//}
//private extension Array {
//	func indexOf(predicate: T->Bool) -> Int? {
//		for i in 0..<count {
//			if predicate(self[i]) {
//				return	i
//			}
//		}
//		return	nil
//	}
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//protocol MonitorType: class {
//}
/////	You must unbind this monitor from any storage.
/////	You cannot change handlers while this monitor is bound to a storage.
/////
//public class StateMonitor<Storage: StorageType>: MonitorType {
//	public typealias	Handler		=	()->()
//	public typealias	SignalHandler	=	Storage.Signal->()
//	
//	public init() {
//	}
//	deinit {
//	}
//	
////	public var willApply: (StateSignal<Storage.Signal>->())? {
////		willSet {
////			assert(_storage != nil)
////		}
////	}
////	public var didApply: (StateSignal<Storage.Signal>->())? {
////		willSet {
////			assert(_storage != nil)
////		}
////	}
//	
//	///	Notifies initiation of new state.
//	public var didInitiate: SignalHandler? {
//		willSet {
//			assert(_online == false)
//		}
//	}
//	
//	///	Notifies application of partial mutation of current state will be started.
//	public var willApply: SignalHandler? {
//		willSet {
//			assert(_online == false)
//		}
//	}
//	
//	///	Notifies application of partial mutation of current state has been finished.
//	public var didApply: SignalHandler? {
//		willSet {
//			assert(_online == false)
//		}
//	}
//	
//	///	Notifies termination of current state.
//	public var willTerminate: SignalHandler? {
//		willSet {
//			assert(_online == false)
//		}
//	}
//	
//	///
//	
//	private var	_online		=	false
//	
//	private func _apply(signal: StateSignal<Storage.Signal>) {
////		willApply?(signal)
//		switch signal {
//		case .DidInitiate(let subsignal):
//			assert(_online == false)
//			_online		=	true
//			didInitiate?(subsignal)
//			
//		case .WillApply(let subsignal):
//			assert(_online == true)
//			willApply?(subsignal)
//			
//		case .DidApply(let subsignal):
//			assert(_online == true)
//			didApply?(subsignal)
//			
//		case .WillTerminate(let subsignal):
//			assert(_online == true)
//			willTerminate?(subsignal)
//			_online		=	false
//		}
////		didApply?(signal)
//	}
//}
//
//
//
//
//
