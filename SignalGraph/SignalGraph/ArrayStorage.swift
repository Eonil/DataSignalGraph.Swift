//
//  ArrayStorage.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/05/05.
//  Copyright (c) 2015 Eonil. All rights reserved.
//









private final class ArraySignalDispatcher<T>: SignalDispatcher<ArraySignal<T>> {
	weak var owner: ArrayStorage<T>?
	override func register(sensor: SignalSensor<ArraySignal<T>>) {
		Debugging.EmitterSensorRegistration.assertRegistrationOfStatefulChannelingSignaling((self, sensor))
		super.register(sensor)
		if let _ = owner!.values {
			sensor.signal(ArraySignal.Initiation(snapshot: owner!.state))
		}
	}
	override func deregister(sensor: SignalSensor<ArraySignal<T>>) {
		Debugging.EmitterSensorRegistration.assertDeregistrationOfStatefulChannelingSignaling((self, sensor))
		super.deregister(sensor)
		if let _ = owner!.values {
			sensor.signal(ArraySignal.Termination(snapshot: owner!.state))
		}
	}
}




///	A data store that provides signal emission but no mutators.
///
///	You should use one of subclasses.
///
public class ArrayStorage<T>: StorageType {
	public typealias	Element	=	T
	
	public var state: [T] {
		get {
			assert(values != nil, "This storage has not been initiated or already terminated. You can initialize by sending `ArraySignal.Initiation` signal.")
			return	values!
		}
	}
	
	public var emitter: SignalEmitter<ArraySignal<T>> {
		get {
			return	dispatcher
		}
	}
	
	////
	
	private var values		=	nil as [T]?
	
	private init() {
		dispatcher.owner	=	self
	}
	
	private let dispatcher		=	ArraySignalDispatcher<T>()
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
	private var editor: ArrayReplicationEditor<T> {
		get {
			return	ArrayReplicationEditor(_replication)
		}
		set(v) {
			assert(v.storage === _replication)
		}
	}
}
extension ArrayReplicationEditor {
	public init(_ storage: EditableArrayStorage<T>) {
		self.init(storage._replication)
	}
}
//extension EditableArrayStorage {
////	public var startIndex: Int { get }
////	public var endIndex: Int { get }
////	public var count: Int { get }
////	public var isEmpty: Bool { get }
////	public var first: T? { get }
////	public var last: T? { get }
//
////	public subscript (index: Int) -> T
////	public subscript (subRange: Range<Int>) -> ArraySlice<T>
////
////	public func generate() -> IndexingGenerator<[T]> {
////		return	state.generate()
////	}
//	
//	public func append(newElement: T) {
//		editor.append(newElement)
//	}
//	public func extend<S : SequenceType where S.Generator.Element == T>(newElements: S) {
//		editor.extend(newElements)
//	}
//	public func removeLast() -> T {
//		return	editor.removeLast()
//	}
//	public func insert(newElement: T, atIndex i: Int) {
//		editor.insert(newElement, atIndex: i)
//	}
//	public func removeAtIndex(index: Int) -> T {
//		return	editor.removeAtIndex(index)
//	}
//	public func removeAll() {
//		editor.removeAll()
//	}
//	public func replaceRange<C : CollectionType where C.Generator.Element == T>(subRange: Range<Int>, with newElements: C) {
//		editor.replaceRange(subRange, with: newElements)
//	}
//	public func splice<S : CollectionType where S.Generator.Element == T>(newElements: S, atIndex i: Int) {
//		editor.splice(newElements, atIndex: i)
//	}
//	public func removeRange(subRange: Range<Int>) {
//		editor.removeRange(subRange)
//	}
//	
//}















































///	A storage that provides indirect signal based mutator.
///
///	Initial state of a state-container is undefined, and you should not access
///	them while this container is not bound to a signal source.
public class ReplicatingArrayStorage<T>: ArrayStorage<T>, ReplicationType {
	
	public override init() {
		super.init()
		monitor.handler	=	{ [unowned self] s in
			s.apply(&self.values)
			self.dispatcher.signal(s)
		}
	}
	
	public var sensor: SignalSensor<ArraySignal<T>> {
		get {
			return	monitor
		}
	}
	
	////
	
	private let	monitor		=	SignalMonitor<ArraySignal<T>>({ _ in })
}









































