//
//  SetStorage.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/05/06.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

























private final class SetSignalDispatcher<T: Hashable>: SignalDispatcher<SetSignal<T>> {
	weak var owner: SetStorage<T>?
	override func register(sensor: SignalSensor<SetSignal<T>>) {
		Debugging.EmitterSensorRegistration.assertRegistrationOfStatefulChannelingSignaling((self, sensor))
		super.register(sensor)
		if let _ = owner!._values {
			sensor.signal(SetSignal.Initiation(snapshot: owner!.state))
		}
	}
	override func deregister(sensor: SignalSensor<SetSignal<T>>) {
		Debugging.EmitterSensorRegistration.assertDeregistrationOfStatefulChannelingSignaling((self, sensor))
		super.deregister(sensor)
		if let _ = owner!._values {
			sensor.signal(SetSignal.Termination(snapshot: owner!.state))
		}
	}
}











public class SetStorage<T: Hashable>: StorageType {
	
	public var state: Set<T> {
		get {
			return	_values!
		}
	}
	
	public var emitter: SignalEmitter<SetSignal<T>> {
		get {
			return	_dispatcher
		}
	}
	
	////
	
	private var	_values		=	nil as Set<T>?
	
	private init() {
	}
	
	private let	_dispatcher	=	SignalDispatcher<SetSignal<T>>()
}

///	A storage that provides indirect signal based mutator.
///
///	Initial state of a state-container is undefined, and you should not access
///	them while this contains is not bound to a signal source.
public class ReplicatingSetStorage<T: Hashable>: SetStorage<T>, ReplicationType {
	
	public override init() {
		super.init()
		_monitor.handler	=	{ [unowned self] s in self._apply(s) }
	}
	
	public var sensor: SignalSensor<SetSignal<T>> {
		get {
			return	_monitor
		}
	}
	
	////
	
	private let	_monitor	=	SignalMonitor<SetSignal<T>>({ _ in })
	
	private func _apply(signal: SetSignal<T>) {
		signal.apply(&self._values)
		self._dispatcher.signal(signal)
	}
}









///	Provides in-place `Set`-like mutator interface.
///	Signal sensor is disabled to guarantee consistency.
public class EditableSetStorage<T: Hashable>: SetStorage<T> {
	public init(_ state: Set<T> = Set()) {
		super.init()
		_replication.sensor.signal(SetSignal.Initiation(snapshot: state))
	}
	deinit {
		_replication.sensor.signal(SetSignal.Termination(snapshot: state))
		//	Do not send any signal.
		//	Because any non-strong reference to self is inaccessible here.
		
		//	We don't need to erase owning current state. Because
		//	users must already been removed all sensors from emitter.
		//	Emitter asserts no registered sensors when `deinit`ializes.
	}
	
	private let	_replication	=	ReplicatingSetStorage<T>()
}

extension EditableSetStorage {
	public typealias	Index	=	SetIndex<T>
	
	public func insert(member: T) {
		_replication.sensor.signal(SetSignal.Transition(transaction: CollectionTransaction.insert((member,()))))
	}
	
	public func remove(member: T) -> T? {
		let	v	=	state.contains(member) ? member : nil as T?
		_replication.sensor.signal(SetSignal.Transition(transaction: CollectionTransaction.delete((member, ()))))
		return	v
	}
	
	public subscript (position: Index) -> T {
		get {
			return	super.state[position]
		}
	}
}
















public class MonitoringSetStorage<T: Hashable>: ReplicatingSetStorage<T> {
	public typealias	SignalHandler		=	SetSignal<T> -> ()
	public var		willApplySignal		:	SignalHandler?
	public var		didApplySignal		:	SignalHandler?
	
	///
	
	private override func _apply(signal: SetSignal<T>) {
		willApplySignal?(signal)
		super._apply(signal)
		didApplySignal?(signal)
	}
}

///	Unlike `MonitoringSetStorage`, this provides you event handlers for
///	each element events liks `insert` or `remove`.
public class TrackingSetStorage<T: Hashable>: ReplicatingSetStorage<T> {
	public typealias	ElementHandler		=	(T,()) -> ()
	public var		willInsert		:	ElementHandler?
	public var		didInsert		:	ElementHandler?
	public var		willDelete		:	ElementHandler?
	public var		didDelete		:	ElementHandler?
	
	///
	
	private override func _apply(signal: SetSignal<T>) {
		switch signal {
		case .Initiation(let snapshot):
			for element in snapshot {
				willInsert?(element,())
			}
			_values		=	snapshot
			for element in snapshot {
				didInsert?(element,())
			}
		case .Transition(let transaction):
			for mutation in transaction.mutations {
				_apply(mutation)
			}
		case .Termination(let snapshot):
			for element in snapshot {
				willDelete?(element,())
			}
			_values		=	nil
			for element in snapshot {
				didDelete?(element,())
			}
		}
		
	}
	
	private func _apply(mutation: CollectionTransaction<T,()>.Mutation) {
		switch (mutation.past != nil, mutation.future != nil) {
		case (false, true):
			//	Insert.
			willInsert?(mutation.identity, ())
			_values!.insert(mutation.identity)
			didInsert?(mutation.identity, ())

		case (true, true):
			//	Update.
			//	Update is invalid in set collection.
			fallthrough
			
		case (true, false):
			//	Delete.
			willDelete?(mutation.identity, ())
			_values!.remove(mutation.identity)
			didDelete?(mutation.identity, ())
			
		default:
			fatalError("Unsupported combination.")
		}
	}
}

















