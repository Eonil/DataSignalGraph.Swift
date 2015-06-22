//
//  CollectionStorage.swift
//  SG2
//
//  Created by Hoon H. on 2015/06/20.
//  Copyright © 2015 Eonil. All rights reserved.
//



public struct CollectionTransaction<K: Hashable, V> {
	public typealias	Mutation	=	(identity: K, past: V?, future: V?)
	
	public var mutations: [Mutation]
}
public protocol CollectionStorageType: StateStorageType {
}

public class CollectionStorage<C: SignallableCollectionType, K: Hashable, V>: StateStorage<CollectionStateDefinition<C, CollectionTransaction<K,V>>> {
	public override init(_ snapshot: Definition.Snapshot) {
		super.init(snapshot)
	}
	
	//	Placed in class definition because Swift 1 does not allow
	//	overriding method in extensions.
	//	Reconsider moving into an extension in Swift 2.
	public subscript(index: C.Index) -> C.Generator.Element {
		get {
			return	super.snapshot[index]
		}
	}
}
extension CollectionStorage: CollectionType {
//	//	NOTE:	Decomment in Swift 2 when ready.
//	public var isEmpty: Bool {
//		get {
//			return	super.snapshot.isEmpty
//		}
//	}	
//	//	NOTE:	Decomment in Swift 2 when ready.
//	public var count: C.Index.Distance {
//		get {
//			return	super.snapshot.count
//		}
//	}
	
	public var startIndex: C.Index {
		get {
			return	super.snapshot.startIndex
		}
	}
	public var endIndex: C.Index {
		get {
			return	super.snapshot.endIndex
		}
	}
	
	public func generate() -> C.Generator {
		return	super.snapshot.generate()
	}
}









































public class SetStorage<T: Hashable>: CollectionStorage<Set<T>, T, ()> {
	public override init(_ snapshot: Definition.Snapshot) {
		super.init(snapshot)
	}
	public func insert(member: T) {
		let	tran	=	_transaction([_insertionMutation(member)])
		_applyWithTransferring(tran)
	}
	public func remove(member: T) {
		let	tran	=	_transaction([_deletionMutation(member)])
		_applyWithTransferring(tran)
	}
	
	///
	
	private typealias	_Signal		=	StateSignal<Definition>
	private typealias	_Transaction	=	CollectionTransaction<T,()>
	
	private func _applyWithTransferring(transaction: _Transaction) {
		apply() { (inout state: Definition.Snapshot)->() in
			let	reason	=	_by(transaction)
			transfer(_Signal.WillEnd(state: {state}, by: {reason}))
			state.apply(transaction)
			transfer(_Signal.DidBegin(state: {state}, by: {reason}))
		}
	}
	private func _by(transaction: _Transaction) -> _Signal.Reason {
		return	_Signal.Reason.StateMutation(by: {transaction})
	}
	private func _transaction(mutations: [_Transaction.Mutation]) -> CollectionTransaction<T,()> {
		return	CollectionTransaction(mutations: mutations)
	}
	private func _insertionMutation(member: T) -> _Transaction.Mutation {
		return	(identity: member, past: nil, future: ())
	}
	private func _deletionMutation(member: T) -> _Transaction.Mutation {
		return	(identity: member, past: (), future: nil)
	}
}
///	Implemented by subclassing due to lack of generic type alias.
class SetMonitor<T: Hashable>: StateMonitor<SetStorage<T>.Definition> {
}




















public class ArrayStorage<T>: CollectionStorage<[T], Int, T> {
	public override init(_ snapshot: Definition.Snapshot) {
		super.init(snapshot)
	}
	
	///
	
	public override subscript(index: Int) -> T {
		get {
			return	super.snapshot[index]
		}
		set(v) {
			let	old	=	super.snapshot[index]
			let	new	=	v
			let	tran	=	_transaction([_updateMutation(index, old: old, new: new)])
			_applyWithTransferring(tran)
		}
	}
	public subscript(subRange: Range<Int>) -> ArraySlice<T> {
		get {
			return	super.snapshot[subRange]
		}
	}
	
	///
	
	public func insert(newElement: T, atIndex index: Int) {
		let	tran	=	_transaction([_insertionMutation(index, v: newElement)])
		_applyWithTransferring(tran)
	}
	public func removeAtIndex(index: Int) {
		let	tran	=	_transaction([_deletionMutation(index)])
		_applyWithTransferring(tran)
	}
	
	
	public func append(newElement: T) {
		let	index	=	super.snapshot.count
		let	tran	=	_transaction([(identity: index, past: nil, future: newElement)])
		_applyWithTransferring(tran)
	}
	
	public func extend<S : SequenceType where S.Generator.Element == T>(newElements: S) {
		var	idx	=	super.snapshot.count
		var	muts	=	Array<_Transaction.Mutation>()
		for e in newElements {
			idx++
			muts.append(_insertionMutation(idx, v: e))
		}
		let	tran	=	_transaction(muts)
		_applyWithTransferring(tran)
	}
	public func removeLast() -> T {
		let	index	=	super.snapshot.count - 1
		let	value	=	super.snapshot.last!
		let	tran	=	_transaction([(identity: index, past: value, future: nil)])
		_applyWithTransferring(tran)
		return	value
	}
	
	public func removeAll() {
		let	muts	=	(0..<super.snapshot.count).map(_deletionMutation)
		let	tran	=	_transaction(muts)
		_applyWithTransferring(tran)
	}
	
	public func join<S : SequenceType where S.Generator.Element == Array<T>>(elements: S) -> [T] {
		return	super.snapshot.join(elements)
	}
	
	///
	
	private typealias	_Signal		=	StateSignal<Definition>
	private typealias	_Transaction	=	CollectionTransaction<Int,T>
	
	private func _applyWithTransferring(transaction: _Transaction) {
		apply() { (inout state: Definition.Snapshot)->() in
			let	reason		=	_by(transaction)
			transfer(_Signal.WillEnd(state: {state}, by: {reason}))
			state.apply(transaction)
			transfer(_Signal.DidBegin(state: {state}, by: {reason}))
		}
	}
	private func _by(transaction: _Transaction) -> _Signal.Reason {
		return	_Signal.Reason.StateMutation(by: {transaction})
	}
	private func _transaction(mutations: [_Transaction.Mutation]) -> _Transaction {
		return	CollectionTransaction(mutations: mutations)
	}
	private func _insertionMutation(i: Int, v: T) -> _Transaction.Mutation {
		return	(identity: i, past: nil, future: v)
	}
	private func _updateMutation(i: Int, old: T, new: T) -> _Transaction.Mutation {
		return	(identity: i, past: old, future: new)
	}
	private func _deletionMutation(i: Int) -> _Transaction.Mutation {
		return	(identity: i, past: super.snapshot[i], future: nil)
	}
}
///	Implemented by subclassing due to lack of generic type alias.
class ArrayMonitor<T>: StateMonitor<ArrayStorage<T>.Definition> {
}

























//extension DictionaryStorage {
//	///	HOTFIX:		To avoid compiler bug.
//	///			Patch to use `subscript` syntax later.
//	public func HOTFIX_subscript_get(key: K) -> V? {
//		return	super.snapshot[key]
//	}
//	///	HOTFIX:		To avoid compiler bug.
//	///			Patch to use `subscript` syntax later.
//	public func HOTFIX_subscript_set(key: K, value: V) {
//		let	past	=	super.snapshot[key]
//		let	mut	=	(key, past, value) as Signal.Mutation
//		let	signal	=	_transaction([mut])
//		_dispatcher.willApply(signal)
//		_collection.apply(signal)
//		_dispatcher.didApply(signal)
//	}
//}
public class DictionaryStorage<K: Hashable, V>: CollectionStorage<[K:V], K, V> {
	public override init(_ snapshot: [K:V]) {
		super.init(snapshot)
	}
	
	///
	
	public subscript(key: K) -> V? {
		get {
			return	super.snapshot[key]
		}
		set(v) {
			let	maybeOld	=	super.snapshot[key]
			let	maybeNew	=	v
			switch (maybeOld, maybeNew) {
			case (nil, nil):
				break
				
			case (_, nil):
				let	tran	=	_transaction([_deleteMutation(key, old: maybeOld!)])
				_applyWithTransferring(tran)
				
			case (nil, _):
				let	tran	=	_transaction([_insertMutation(key, new: maybeNew!)])
				_applyWithTransferring(tran)
				
			case (_, _):
				let	tran	=	_transaction([_updateMutation(key, old: maybeOld!, new: maybeNew!)])
				_applyWithTransferring(tran)
			}
		}
	}

	///
	
	public func updateValue(value: V, forKey key: K) -> V? {
		let	maybeOld	=	super.snapshot[key]
		let	new		=	value
		if let old = maybeOld {
			let	tran		=	_transaction([_updateMutation(key, old: old, new: new)])
			_applyWithTransferring(tran)
		}
		return	maybeOld
	}
	
	public func removeAtIndex(index: DictionaryIndex<K, V>) {
		let	pair	=	super.snapshot[index]
		let	key	=	pair.0
		let	old	=	pair.1
		let	tran	=	_transaction([_deleteMutation(key, old: old)])
		_applyWithTransferring(tran)
	}
	
	public func removeValueForKey(key: K) -> V? {
		let	maybeOld	=	super.snapshot[key]
		if let old = maybeOld {
			let	tran		=	_transaction([_deleteMutation(key, old: old)])
			_applyWithTransferring(tran)
		}
		return	maybeOld
	}
	
	public func removeAll() {
		var	muts		=	Array<_Transaction.Mutation>()
		for (k,v) in super.snapshot {
			muts.append(_deleteMutation(k, old: v))
		}
		let	tran		=	_transaction(muts)
		_applyWithTransferring(tran)
	}
	
	public var keys: LazyForwardCollection<MapCollectionView<[K:V],K>> {
		get {
			return	super.snapshot.keys
		}
	}
	public var values: LazyForwardCollection<MapCollectionView<[K:V],V>> {
		get {
			return	super.snapshot.values
		}
	}
	
	///
	
	private typealias	_Signal		=	StateSignal<Definition>
	private typealias	_Transaction	=	CollectionTransaction<K,V>
	
	private func _applyWithTransferring(transaction: _Transaction) {
		apply() { (inout state: Definition.Snapshot)->() in
			let	reason		=	_by(transaction)
			transfer(_Signal.WillEnd(state: {state}, by: {reason}))
			state.apply(transaction)
			transfer(_Signal.DidBegin(state: {state}, by: {reason}))
		}
	}
	private func _by(transaction: _Transaction) -> _Signal.Reason {
		return	_Signal.Reason.StateMutation(by: {transaction})
	}
	private func _transaction(mutations: [_Transaction.Mutation]) -> _Transaction {
		return	_Transaction(mutations: mutations)
	}
	private func _insertMutation(key: K, new: V) -> _Transaction.Mutation {
		return	(identity: key, past: nil, future: new)
	}
	private func _updateMutation(key: K, old: V, new: V) -> _Transaction.Mutation {
		return	(identity: key, past: old, future: new)
	}
	private func _deleteMutation(key: K, old: V) -> _Transaction.Mutation {
		return	(identity: key, past: old, future: nil)
	}
}
///	Implemented by subclassing due to lack of generic type alias.
class DictionaryMonitor<K: Hashable, V>: StateMonitor<DictionaryStorage<K,V>.Definition> {
}
















public class DictionaryFilteringDictionaryStorage<K: Hashable, V>: SignalSensor<DictionaryStorage<K,V>.Definition>, StateStorageType {
	public typealias	Definition	=	DictionaryStorage<K,V>.Definition
	
	public override init() {
		super.init()
	}
	public convenience init(filter: ((K,V)->Bool)) {
		self.init()
		self.filter	=	filter
	}
	deinit {
		filter	=	nil
	}

	///
	
	public var snapshot: Definition.Snapshot {
		get {
			return	_storage.snapshot
		}
	}
	public var filter: ((K,V)->Bool)? {
		willSet {
			_disconnect()
		}
		didSet {
			_connect()
		}
	}
	
	///
	
	public func register(sensor: SignalSensor<Definition.Signal>) {
		_storage.register(sensor)
	}
	public func deregister(sensor: SignalSensor<Definition.Signal>) {
		_storage.deregister(sensor)
	}
	final func register(monitor: StateMonitor<Definition>) {
		_storage.register(monitor)
	}
	final func deregister(monitor: StateMonitor<Definition>) {
		_storage.deregister(monitor)
	}
	
	///
	
	private let	_storage	=	DictionaryStorage<K,V>([:])
	private let	_monitor	=	StateMonitor<Definition>()
	
	private func _connect() {
		_assertFilterExistence()
		_monitor.didBegin		=	{ [weak self] in self!._didBegin($0, by: $1) }
		_monitor.willEnd		=	{ [weak self] in self!._willEnd($0, by: $1) }
		_storage.register(_monitor)
	}
	private func _disconnect() {
		_assertFilterExistence()
		_storage.deregister(_monitor)
		_monitor.willEnd		=	nil
		_monitor.didBegin		=	nil
	}
	
	private func _didBegin(state: Definition.Snapshot, by: StateSessionNotificationReason<Definition>) {
		_assertFilterExistence()
	}
	private func _willEnd(state: Definition.Snapshot, by: StateSessionNotificationReason<Definition>) {
		_assertFilterExistence()
		
	}
	private func _assertFilterExistence() {
		assert(filter != nil, "You must set a filter before registering this storage to a source storage.")
	}
}

public class DictionarySortingArrayStorage<K: Hashable, V>: StateMonitor<DictionaryStorage<K,V>.Definition>, StateStorageType {
	public typealias	Definition	=	ArrayStorage<V>.Definition
	
	public init(_ snapshot: Definition.Snapshot) {
		self.snapshot	=	snapshot
	}
	public var snapshot: Definition.Snapshot
}

public class ValueMappingArrayStorage<T,U>: StateMonitor<ArrayStorage<T>.Definition>, StateStorageType {
	public typealias	Definition	=	ArrayStorage<U>.Definition
	
	public init(_ snapshot: Definition.Snapshot) {
		self.snapshot	=	snapshot
	}
	public var snapshot: Definition.Snapshot
}


































public protocol CollectionStateDefinitionType: StateDefinitionType {
	typealias		Signal
}
public struct CollectionStateDefinition<C: CollectionType, T>: CollectionStateDefinitionType {
	public typealias	Snapshot	=	C
	public typealias	Transaction	=	T
	public typealias	Signal		=	StateSignal<CollectionStateDefinition<C,T>>
}
//	NOTE:	Change to `public` in Swift 2 when ready.
public protocol SignallableCollectionType: CollectionType {
	typealias		Definition	:	CollectionStateDefinitionType
	
	//	mutating func apply(transaction: Definition.Transaction)
}



extension Set: SignallableCollectionType {
	//	NOTE:	Change to `public` in Swift 2 when ready.
	typealias	Definition	=	CollectionStateDefinition<Set<T>, CollectionTransaction<T,()>>
	
	//	NOTE:	Change to `public` in Swift 2 when ready.
	mutating func apply(transaction: Definition.Transaction) {
		for m in transaction.mutations {
			switch (m.past, m.future) {
			case (nil, nil):
				fatalError("Illegal signal mutation combination.")
			case (nil, _):
				insert(m.identity)
			case (_, nil):
				remove(m.identity)
			case (_, _):
				fatalError("Illegal signal mutation combination for `SetSignal`.")
			}
		}
	}
	
}
extension Array: SignallableCollectionType {
	//	NOTE:	Change to `public` in Swift 2 when ready.
	typealias	Definition	=	CollectionStateDefinition<[T], CollectionTransaction<Int,T>>
	
	//	NOTE:	Change to `public` in Swift 2 when ready.
	mutating func apply(transaction: Definition.Transaction) {
		for m in transaction.mutations {
			switch (m.past, m.future) {
			case (nil, nil):
				fatalError("Illegal signal mutation combination.")
			case (nil, _):
				assert(m.identity <= count)
				insert(m.future!, atIndex: m.identity)
			case (_, nil):
				assert(m.identity < count)
				removeAtIndex(m.identity)
			case (_, _):
				assert(m.identity < count)
				self[m.identity]	=	m.future!
			}
		}
	}
}
extension Dictionary: SignallableCollectionType {
	//	NOTE:	Change to `public` in Swift 2 when ready.
	typealias	Definition	=	CollectionStateDefinition<[Key:Value], CollectionTransaction<Key,Value>>
	
	//	NOTE:	Change to `public` in Swift 2 when ready.
	mutating func apply(transaction: Definition.Transaction) {
		for m in transaction.mutations {
			switch (m.past, m.future) {
			case (nil, nil):
				fatalError("Illegal signal mutation combination.")
			case (nil, _):
				self[m.identity]	=	m.future!
			case (_, nil):
				assert(self[m.identity] != nil)
				removeValueForKey(m.identity)
			case (_, _):
				assert(self[m.identity] != nil)
				self[m.identity]	=	m.future!
			}
		}
	}
}

















































































































































//public protocol SignallableCollectionType: CollectionType {
//	typealias	SignalKey	:	Hashable
//	typealias	SignalValue
//	mutating func apply(signal: CollectionSignal<Self, SignalKey, SignalValue>)
//}
//extension Set: SignallableCollectionType {
//	public typealias	SignalKey	=	Generator.Element
//	public typealias	SignalValue	=	()
//	public mutating func apply(signal: CollectionSignal<Set, SignalKey, SignalValue>) {
//		switch signal {
//		case .Snapshot(let snapshot):
//			self	=	snapshot
//			
//		case .Transaction(let mutations):
//			for m in mutations {
//				switch (m.past, m.future) {
//				case (nil, nil):
//					fatalError("Illegal signal mutation combination.")
//				case (nil, _):
//					insert(m.identity)
//				case (_, nil):
//					remove(m.identity)
//				case (_, _):
//					fatalError("Illegal signal mutation combination for `SetSignal`.")
//				}
//			}
//		}
//	}
//}
//extension Array: SignallableCollectionType {
//	public typealias	SignalKey	=	Int
//	public typealias	SignalValue	=	Generator.Element
//	public mutating func apply(signal: CollectionSignal<Array, SignalKey, SignalValue>) {
//		switch signal {
//		case .Snapshot(let snapshot):
//			self	=	snapshot
//			
//		case .Transaction(let mutations):
//			for m in mutations {
//				switch (m.past, m.future) {
//				case (nil, nil):
//					fatalError("Illegal signal mutation combination.")
//				case (nil, _):
//					assert(m.identity <= count)
//					insert(m.future!, atIndex: m.identity)
//				case (_, nil):
//					assert(m.identity < count)
//					removeAtIndex(m.identity)
//				case (_, _):
//					assert(m.identity < count)
//					self[m.identity]	=	m.future!
//				}
//			}
//		}
//	}
//}
//extension Dictionary: SignallableCollectionType {
//	public typealias	SignalKey	=	Key
//	public typealias	SignalValue	=	Value
//	public mutating func apply(signal: CollectionSignal<Dictionary, SignalKey, SignalValue>) {
//		switch signal {
//		case .Snapshot(let snapshot):
//			self	=	snapshot
//			
//		case .Transaction(let mutations):
//			for m in mutations {
//				switch (m.past, m.future) {
//				case (nil, nil):
//					fatalError("Illegal signal mutation combination.")
//				case (nil, _):
//					self[m.identity]	=	m.future!
//				case (_, nil):
//					assert(self[m.identity] != nil)
//					removeValueForKey(m.identity)
//				case (_, _):
//					assert(self[m.identity] != nil)
//					self[m.identity]	=	m.future!
//				}
//			}
//		}
//	}
//}

//public enum CollectionSignal<C: SignallableCollectionType, K: Hashable, V> {
//	public typealias	Mutation	=	(identity: K, past: V?, future: V?)
//	
//	case Snapshot(C)
//	case Transaction([Mutation])
//}
//public protocol CollectionStorageType: StorageType {
//}
//public class CollectionStorage<C: SignallableCollectionType, K: Hashable, V>: StorageType, CollectionStorageType {
//	public typealias	State	=	C
//	public typealias	Signal	=	CollectionSignal<C, K, V>
//	public typealias	Monitor	=	StateMonitor<CollectionStorage<C, K, V>>
//	
//	public init(_ snapshot: C) {
//		self._collection	=	snapshot
//	}
//	deinit {
//	}
//	
//	public var snapshot: C {
//		get {
//			return	_collection
//		}
//		set(v) {
//			_dispatcher.willApply(Signal.Snapshot(v))
//			_collection	=	v
//			_dispatcher.didApply(Signal.Snapshot(snapshot))
//		}
//	}
//	
//	public func register(monitor: Monitor) {
//		_dispatcher.register(monitor)
//		_dispatcher.willApply(Signal.Snapshot(_collection))
//		_dispatcher.didApply(Signal.Snapshot(_collection))
//	}
//	public func deregister(monitor: Monitor) {
//		_dispatcher.willApply(Signal.Snapshot(_collection))
//		_dispatcher.didApply(Signal.Snapshot(_collection))
//		_dispatcher.deregister(monitor)
//	}
//	
//	///
//	
//	internal var dispatcher: StateDispatcher<CollectionStorage<C, K, V>> {
//		get {
//			return	_dispatcher
//		}
//	}
//	
//	///
//	
//	private let	_dispatcher	=	StateDispatcher<CollectionStorage<C, K, V>>()
//	private var 	_collection	:	C
//}
//extension CollectionStorage: CollectionType {
//	public var isEmpty: Bool {
//		get {
//			return	_collection.isEmpty
//		}
//	}
//	public var count: C.Index.Distance {
//		get {
//			return	_collection.count
//		}
//	}
//	
//	public var startIndex: C.Index {
//		get {
//			return	_collection.startIndex
//		}
//	}
//	public var endIndex: C.Index {
//		get {
//			return	_collection.endIndex
//		}
//	}
//	
//	public func generate() -> C.Generator {
//		return	_collection.generate()
//	}
//	public subscript(index: C.Index) -> C.Generator.Element {
//		get {
//			return	_collection[index]
//		}
//	}
//}
////extension CollectionStorageType where State == MutableCollectionType {
////	public subscript(index: C.Index)
////}
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
//public class SetStorage<T: Hashable>: CollectionStorage<Set<T>, T, ()> {
//	public override init(_ snapshot: Set<T>) {
//		super.init(snapshot)
//	}
//	public func insert(member: T) {
//		let	signal	=	CollectionSignal<Set<T>, T, ()>.Transaction([(identity: member, past: nil, future: ())])
//		_dispatcher.willApply(signal)
//		_collection.apply(signal)
//		_dispatcher.didApply(signal)
//	}
//	public func remove(member: T) {
//		let	signal	=	CollectionSignal<Set<T>, T, ()>.Transaction([(identity: member, past: (), future: nil)])
//		_dispatcher.willApply(signal)
//		_collection.apply(signal)
//		_dispatcher.didApply(signal)
//	}
//}
/////	Implemented by subclassing due to lack of generic type alias.
//class SetMonitor<T: Hashable>: StateMonitor<CollectionStorage<Set<T>, T, ()>> {
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
//public class ArrayStorage<T>: CollectionStorage<[T], Int, T> {
//	public override init(_ snapshot: [T]) {
//		super.init(snapshot)
//	}
//	public func insert(newElement: T, atIndex index: Int) {
//		let	signal	=	_transaction([_insertionMutation(index, v: newElement)])
//		_dispatcher.willApply(signal)
//		_collection.apply(signal)
//		_dispatcher.didApply(signal)
//	}
//	public func removeAtIndex(index: Int) {
//		let	signal	=	_transaction([_deletionMutation(index)])
//		_dispatcher.willApply(signal)
//		_collection.apply(signal)
//		_dispatcher.didApply(signal)
//	}
//	
////	public subscript (subRange: Range<Int>) -> ArraySlice<T> {
////		get {
////			return	super.snapshot[subRange]
////		}
////	}
//	
//	
//	public func append(newElement: T) {
//		let	index	=	_collection.count
//		let	signal	=	_transaction([(identity: index, past: nil, future: newElement)])
//		_dispatcher.willApply(signal)
//		_collection.apply(signal)
//		_dispatcher.didApply(signal)
//	}
//
//	public func extend<S : SequenceType where S.Generator.Element == T>(newElements: S) {
//		var	idx	=	_collection.count
//		var	muts	=	Array<CollectionSignal<[T], Int, T>.Mutation>()
//		for e in newElements {
//			idx++
//			muts.append(_insertionMutation(idx, v: e))
//		}
//		let	signal	=	_transaction(muts)
//		_dispatcher.willApply(signal)
//		_collection.apply(signal)
//		_dispatcher.didApply(signal)
//	}
//	public func removeLast() -> T {
//		let	index	=	_collection.count - 1
//		let	value	=	_collection.last!
//		let	signal	=	_transaction([(identity: index, past: value, future: nil)])
//		_dispatcher.willApply(signal)
//		_collection.apply(signal)
//		_dispatcher.didApply(signal)
//		return	value
//	}
//
//	public func removeAll() {
//		let	muts	=	(0..<_collection.count).map(_deletionMutation)
//		let	signal	=	_transaction(muts)
//		_dispatcher.willApply(signal)
//		_collection.apply(signal)
//		_dispatcher.didApply(signal)
//	}
//
//	public func join<S : SequenceType where S.Generator.Element == Array<T>>(elements: S) -> [T] {
//		return	_collection.join(elements)
//	}
//	
//	private func _transaction(mutations: [Signal.Mutation]) -> Signal {
//		return	CollectionSignal<[T], Int, T>.Transaction(mutations)
//	}
//	private func _insertionMutation(i: Int, v: T) -> Signal.Mutation {
//		return	(i, nil, v)
//	}
//	private func _deletionMutation(i: Int) -> Signal.Mutation {
//		return	(i, _collection[i], nil)
//	}
//}
/////	Implemented by subclassing due to lack of generic type alias.
//class ArrayMonitor<T>: StateMonitor<CollectionStorage<[T], Int, T>> {
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
//extension DictionaryStorage {
//	///	HOTFIX:		To avoid compiler bug.
//	///			Patch to use `subscript` syntax later.
//	public func HOTFIX_subscript_get(key: K) -> V? {
//		return	_collection[key]
//	}
//	///	HOTFIX:		To avoid compiler bug.
//	///			Patch to use `subscript` syntax later.
//	public func HOTFIX_subscript_set(key: K, value: V) {
//		let	past	=	_collection[key]
//		let	mut	=	(key, past, value) as Signal.Mutation
//		let	signal	=	_transaction([mut])
//		_dispatcher.willApply(signal)
//		_collection.apply(signal)
//		_dispatcher.didApply(signal)
//	}
//}
//public class DictionaryStorage<K: Hashable, V>: CollectionStorage<[K:V], K, V> {
//	public override init(_ snapshot: [K:V]) {
//		super.init(snapshot)
//	}
//	
//
//	public func updateValue(value: V, forKey key: K) -> V? {
//		let	past	=	_collection[key]
//		let	signal	=	CollectionSignal<[K:V], K, V>.Transaction([(identity: key, past: past, future: value)])
//		_dispatcher.willApply(signal)
//		_collection.apply(signal)
//		_dispatcher.didApply(signal)
//		return	past
//	}
//	
//	public func removeAtIndex(index: DictionaryIndex<K, V>) {
//		let	pair	=	_collection[index]
//		let	key	=	pair.0
//		let	past	=	pair.1
//		let	signal	=	CollectionSignal<[K:V], K, V>.Transaction([(identity: key, past: past, future: nil)])
//		_dispatcher.willApply(signal)
//		_collection.apply(signal)
//		_dispatcher.didApply(signal)
//	}
//	
//	public func removeValueForKey(key: K) -> V? {
//		let	past	=	_collection[key]
//		let	signal	=	CollectionSignal<[K:V], K, V>.Transaction([(identity: key, past: past, future: nil)])
//		_dispatcher.willApply(signal)
//		_collection.apply(signal)
//		_dispatcher.didApply(signal)
//		return	past
//	}
//	
//	public func removeAll() {
//		let	signal	=	CollectionSignal<[K:V], K, V>.Snapshot([:])
//		_dispatcher.willApply(signal)
//		_collection.apply(signal)
//		_dispatcher.didApply(signal)
//	}
//	
//	public var keys: LazyForwardCollection<MapCollectionView<[K:V],K>> {
//		get {
//			return	_collection.keys
//		}
//	}
//	public var values: LazyForwardCollection<MapCollectionView<[K:V],V>> {
//		get {
//			return	_collection.values
//		}
//	}
//
//	///
//	
//	private func _transaction(mutations: [Signal.Mutation]) -> Signal {
//		return	CollectionSignal<[K:V],K,V>.Transaction(mutations)
//	}
//}
/////	Implemented by subclassing due to lack of generic type alias.
//class DictionaryMonitor<K: Hashable, V>: StateMonitor<CollectionStorage<[K:V], K, V>> {
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
//public class DictionaryFilteringDictionaryStorage<K: Hashable, V>: StateMonitor<DictionaryStorage<K,V>>, StorageType {
//	public typealias	State		=	[K:V]
//	public typealias	Signal		=	DictionaryStorage<K,V>.Signal
//	
//	public init(_ snapshot: State) {
//		self.snapshot	=	snapshot
//	}
//	public var snapshot: State
//}
//
//public class DictionarySortingArrayStorage<K: Hashable, V>: StateMonitor<DictionaryStorage<K,V>>, StorageType {
//	public typealias	State		=	[V]
//	public typealias	Signal		=	ArrayStorage<V>.Signal
//	
//	public init(_ snapshot: State) {
//		self.snapshot	=	snapshot
//	}
//	public var snapshot: State
//}
//
//public class ValueMappingArrayStorage<T,U>: StateMonitor<ArrayStorage<T>>, StorageType {
//	public typealias	State		=	[U]
//	public typealias	Signal		=	ArrayStorage<U>.Signal
//	
//	public init(_ snapshot: State) {
//		self.snapshot	=	snapshot
//	}
//	public var snapshot: State
//}
//
//








