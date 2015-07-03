//
//  StateStorage.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/01.
//  Copyright © 2015 Eonil. All rights reserved.
//

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









public protocol TransactionType {
	typealias	Mutation
}
public protocol TransactionApplicable {
	typealias	Transaction	:	TransactionType
	mutating func apply(transaction: Transaction)
}
public protocol TransactionalStorageType: StorageType, TransactionApplicable {
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
//	typealias	Transaction	=	CollectionTransaction<Int,Element>
	typealias	Transaction	=	CollectionTransaction<Range<Int>,[Element]>
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













