//
//  ArrayStorage.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/05/05.
//  Copyright (c) 2015 Eonil. All rights reserved.
//












///	A data store that provides signal emission but no mutators.
///
///	You should use one of subclasses.
///
public class ArrayStorage<T>: StorageType {
	public typealias	Element	=	T
	
	public var state: [T] {
		get {
			assert(_elements != nil, "This storage has not been initiated or already terminated. You can initialize by sending `ArraySignal.Initiation` signal.")
			return	_elements!
		}
	}
	
	public var emitter: SignalEmitter<ArraySignal<T>> {
		get {
			return	_dispatcher
		}
	}
	
	////
	
	private var _elements		=	nil as [T]?
	
	private init() {
		_dispatcher.owner	=	self
	}
	
	private let _dispatcher		=	_ReplicatingArrayStorageSignalDispatcher<T>()
}














///	A directly writable replicating array storage.
public class EditableArrayStorage<T>: ArrayStorage<T> {
	public init(_ state: [T] = []) {
		super.init()
		_replication.sensor.signal(ArraySignal.Initiation(snapshot: state))
	}
	deinit {
		//	We don't need to erase owning current state. Because
		//	users must already been removed all sensors from emitter.
		//	Emitter asserts no registered sensors when `deinit`ializes.
	}
	
	public override var state: [T] {
		get {
			return	_replication.state
		}
	}
	
	///
	
	private let	_replication	=	ReplicatingArrayStorage<T>()
	
	///	Hacky tricky solution.
	private var editor: ArrayStorageEditor<T> {
		get {
			return	ArrayStorageEditor(_replication)
		}
		set(v) {
			assert(v.storage === _replication)
		}
	}
}
extension ArrayStorageEditor {
	public init(_ storage: EditableArrayStorage<T>) {
		self.init(storage._replication)
	}
}
extension EditableArrayStorage {
//	public var startIndex: Int { get }
//	public var endIndex: Int { get }
//	public var count: Int { get }
//	public var isEmpty: Bool { get }
//	public var first: T? { get }
//	public var last: T? { get }

//	public subscript (index: Int) -> T
//	public subscript (subRange: Range<Int>) -> ArraySlice<T>
//
//	public func generate() -> IndexingGenerator<[T]> {
//		return	state.generate()
//	}
	
	public func append(newElement: T) {
		editor.append(newElement)
	}
	public func extend<S : SequenceType where S.Generator.Element == T>(newElements: S) {
		editor.extend(newElements)
	}
	public func removeLast() -> T {
		return	editor.removeLast()
	}
	public func insert(newElement: T, atIndex i: Int) {
		editor.insert(newElement, atIndex: i)
	}
	public func removeAtIndex(index: Int) -> T {
		return	editor.removeAtIndex(index)
	}
	public func removeAll() {
		editor.removeAll()
	}
	public func replaceRange<C : CollectionType where C.Generator.Element == T>(subRange: Range<Int>, with newElements: C) {
		editor.replaceRange(subRange, with: newElements)
	}
	public func splice<S : CollectionType where S.Generator.Element == T>(newElements: S, atIndex i: Int) {
		editor.splice(newElements, atIndex: i)
	}
	public func removeRange(subRange: Range<Int>) {
		editor.removeRange(subRange)
	}
	
}















































///	A storage that provides indirect signal based mutator.
///
///	Initial state of a state-container is undefined, and you should not access
///	them while this container is not bound to a signal source.
public class ReplicatingArrayStorage<T>: ArrayStorage<T>, ReplicationType {
	
	public override init() {
		super.init()
		_monitor.handler	=	{ [unowned self] s in self._apply(s) }
	}
	
	public var sensor: SignalSensor<ArraySignal<T>> {
		get {
			return	_monitor
		}
	}
	
	////
	
	private let	_monitor	=	SignalMonitor<ArraySignal<T>>({ _ in })
	
	private func _apply(signal: ArraySignal<T>) {
		signal.apply(&_elements)
		_dispatcher.signal(signal)
	}
}

private final class _ReplicatingArrayStorageSignalDispatcher<T>: SignalDispatcher<ArraySignal<T>> {
	weak var owner: ArrayStorage<T>?
	override func register(sensor: SignalSensor<ArraySignal<T>>) {
		Debugging.EmitterSensorRegistration.assertRegistrationOfStatefulChannelingSignaling((self, sensor))
		super.register(sensor)
		if let _ = owner!._elements {
			sensor.signal(ArraySignal.Initiation(snapshot: owner!.state))
		}
	}
	override func deregister(sensor: SignalSensor<ArraySignal<T>>) {
		Debugging.EmitterSensorRegistration.assertDeregistrationOfStatefulChannelingSignaling((self, sensor))
		super.deregister(sensor)
		if let _ = owner!._elements {
			sensor.signal(ArraySignal.Termination(snapshot: owner!.state))
		}
	}
}
























public class MonitoringArrayStorage<T>: ReplicatingArrayStorage<T> {
	public typealias	SignalHandler		=	ArraySignal<T> -> ()
	public var		willApplySignal		:	SignalHandler?
	public var		didApplySignal		:	SignalHandler?
	
	///
	
	private override func _apply(signal: ArraySignal<T>) {
		willApplySignal?(signal)
		super._apply(signal)
		didApplySignal?(signal)
	}
}



///	Unlike `MonitoringArrayStorage`, this provides you event handlers for
///	each element events liks `insert` or `delete`.
public class TrackingArrayStorage<T>: ReplicatingArrayStorage<T> {
	public typealias	ElementHandler		=	CollectionTransaction<Int,T>.Mutation -> ()
	public var		willInsert		:	ElementHandler?
	public var		didInsert		:	ElementHandler?
	public var		willUpdate		:	ElementHandler?
	public var		didUpdate		:	ElementHandler?
	public var		willDelete		:	ElementHandler?
	public var		didDelete		:	ElementHandler?
	
	///
	
	private override func _apply(signal: ArraySignal<T>) {
		switch signal {
		case .Initiation(let snapshot):
			for (i, e) in enumerate(snapshot) {
				willInsert?((i, nil, e))
			}
			_elements	=	snapshot
			for (i, e) in enumerate(snapshot) {
				didInsert?((i, nil, e))
			}
		case .Transition(let transaction):
			for mutation in transaction.mutations {
				_apply(mutation)
			}
		case .Termination(let snapshot):
			for (i, e) in enumerate(snapshot) {
				willDelete?((i, nil, e))
			}
			_elements	=	nil
			for (i, e) in enumerate(snapshot) {
				didDelete?((i, nil, e))
			}
		}
	}
	
	private func _apply(mutation: CollectionTransaction<Int,T>.Mutation) {
		switch (mutation.past != nil, mutation.future != nil) {
		case (false, true):
			//	Insert.
			assert(mutation.past == nil)
			willInsert?(mutation)
			_elements!.insert(mutation.future!, atIndex: mutation.identity)
			didInsert?(mutation)
			
		case (true, true):
			//	Update.
			willUpdate?(mutation)
			_elements![mutation.identity]	=	mutation.future!
			didUpdate?(mutation)
			
		case (true, false):
			//	Delete.
			assert(mutation.future == nil)
			willDelete?(mutation)
			_elements!.removeAtIndex(mutation.identity)
			didDelete?(mutation)
			
		default:
			fatalError("Unsupported combination `\(mutation)` cannot be processed.")
		}
	}
}





























