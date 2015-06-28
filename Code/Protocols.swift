//
//  Protocols.swift
//  SG4
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//





public protocol Emittable {
	typealias	OutgoingSignal
	func register(identifier: ObjectIdentifier, handler: OutgoingSignal->())
	func deregister(identifier: ObjectIdentifier)
}
public protocol Sensible {
	typealias	IncomingSignal
	func cast(IncomingSignal)
}





public protocol StationType: class {
}
public protocol EmissiveStationType: StationType, Emittable {
	func register<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal>(S)
	func deregister<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal>(S)
}
public protocol SensitiveStationType: StationType, Sensible {
}
public protocol RelayingStationType: SensitiveStationType, EmissiveStationType {
}
public protocol DelayingStationType: RelayingStationType {

}
///	Manually delaying station.
public protocol DeferringStationType: DelayingStationType {
	func wait()
	func go()
}










public protocol Viewable {
	typealias	Snapshot
	var snapshot: Snapshot { get }
}
public protocol Editable: Viewable {
	var snapshot: Snapshot { get set }
}
public protocol ChannelType: StationType, Viewable {
}
public protocol StorageType: ChannelType, Editable {
}

public protocol WatchableChannelType: ChannelType, EmissiveStationType {
}
public protocol WatchableStorageType: StorageType, EmissiveStationType {
}










public protocol TransactionApplicable {
	typealias	Transaction
	mutating func apply(transaction: Transaction)
}
public protocol TransactionalStorageType: StorageType, TransactionApplicable {
}
















public enum StateSignalingTiming {
	case DidBegin
	case WillEnd
}
public protocol StateSignalType {
	typealias	Snapshot
	typealias	Transaction
	var timing	:	StateSignalingTiming	{ get }
	var state	:	Snapshot		{ get }
	var by		:	Transaction?		{ get }
}




public protocol CollectionTransactionType {
	typealias	Identity
	typealias	State
	typealias	Mutation	=	(identity: Identity, past: State?, future: State?)
	var mutations: [Mutation] { get }
}
public struct CollectionTransaction<K,V>: CollectionTransactionType {
	typealias	Identity	=	K
	typealias	State		=	V
	typealias	Mutation	=	(identity: K, past: V?, future: V?)
	public var mutations: [Mutation]

	public init(_ mutations: [Mutation]) {
		self.mutations	=	mutations
	}
}
public struct StateSignal<S,T>: StateSignalType {
	typealias	Transaction	=	T
	public var timing: StateSignalingTiming
	public var state: S
	public var by: T?
}
public extension StateSignal {
	static func didBegin(state: S, by: T?) -> StateSignal {
		return	StateSignal(timing: .DidBegin, state: state, by: by)
	}
	static func willEnd(state: S, by: T?) -> StateSignal {
		return	StateSignal(timing: .WillEnd, state: state, by: by)
	}
}
public protocol StateChannelType: ChannelType, EmissiveStationType {
	typealias	State		=	Snapshot
	typealias	OutgoingSignal	:	StateSignalType
}
public protocol StateStorageType: StateChannelType, TransactionalStorageType {
}




public protocol ValueChannelType: StateChannelType {
	var state: State { get }
}
public protocol ValueStorageType: ValueChannelType, StateStorageType {
	var state: State { get set }
}



public protocol CollectionChannelType: StateChannelType {
	typealias	Transaction	:	CollectionTransactionType
}
public protocol CollectionStorageType: StateStorageType {
}
public protocol SetChannelType: CollectionChannelType {
	typealias	Element		:	Hashable
	typealias	Snapshot	=	Set<Element>
	typealias	Transaction	=	CollectionTransaction<Element,()>
	typealias	OutgoingSignal	=	StateSignal<Snapshot,Transaction>
}
public protocol SetStorageType: SetChannelType, CollectionStorageType {
}
public protocol ArrayChannelType: CollectionChannelType {
	typealias	Element
	typealias	Snapshot	=	[Element]
	typealias	Transaction	=	CollectionTransaction<Int,Element>
	typealias	OutgoingSignal	=	StateSignal<Snapshot,Transaction>
}
public protocol ArrayStorageType: ArrayChannelType, CollectionStorageType {
}
public protocol DictionaryChannelType: CollectionChannelType {
	typealias	Key		:	Hashable
	typealias	Value
	typealias	Snapshot	=	[Key:Value]
	typealias	Transaction	=	CollectionTransaction<Key,Value>
	typealias	OutgoingSignal	=	StateSignal<Snapshot,Transaction>
}
public protocol DictionaryStorageType: DictionaryChannelType, CollectionStorageType {
}
















public protocol Countable {
	var count: Int { get }
}
public protocol ViewableSet: Viewable, Countable, SequenceType {
}
public protocol EditableSet: ViewableSet, Editable, Countable {
	typealias	Element		:	Hashable
	mutating func insert(member: Element)
	mutating func remove(member: Element) -> Element?
}

public protocol ViewableArray: Viewable, Countable {
	typealias	Element
	subscript(index: Int) -> Element { get }
}
public protocol EditableArray: ViewableArray, Editable {
	typealias	Element
	subscript(index: Int) -> Element { get set }
}

public protocol ViewableDictionary: Viewable, Countable {
	typealias	Key		:	Hashable
	typealias	Value
	subscript(key: Key) -> Value? { get }
}
public protocol EditableDictionary: ViewableDictionary, Editable {
	//	Compiler fail. Ah...
//	subscript(key: Key) -> Value? { get set }
}















public protocol SetFilteringSetChannelType: SetChannelType, RelayingStationType {
	typealias	IncomingSignal	=	StateSignal<Set<Element>,CollectionTransaction<Element,()>>
	var filter: (Element->Bool)? { get set }
}
public protocol DictionaryFilteringDictionaryChannelType: DictionaryChannelType, RelayingStationType {
	typealias	IncomingSignal	=	StateSignal<[Key:Value],CollectionTransaction<Key,Value>>
	var filter: ((Key,Value)->Bool)? { get set }
}
///	"sorting" means re-ordering of existing fixed data set.
///	"ordering" means mutating a data set keeping ordering between elements.
public protocol DictionaryOrderingArrayChannelType: ArrayChannelType, RelayingStationType {
	typealias	Key		:	Hashable
	typealias	Value
	typealias	Order		:	Comparable
	typealias	Element		=	(Key,Value)
	typealias	IncomingSignal	=	StateSignal<[Key:Value],CollectionTransaction<Key,Value>>
	var order: ((Key,Value)->Order)? { get set }
}
public protocol ArrayMappingArrayChannelType: ArrayChannelType, RelayingStationType {
	typealias	IncomingElement
	typealias	OutgoingElement
	typealias	Element		=	OutgoingElement
	typealias	IncomingSignal	=	StateSignal<[IncomingElement],CollectionTransaction<Int,IncomingElement>>
	var map: (IncomingElement->OutgoingElement)? { get set }
}














