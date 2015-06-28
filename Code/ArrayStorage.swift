//
//  ArrayStorage.swift
//  SG4
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class ArrayStorage<T>: ArrayStorageType {
	typealias	Element			=	T
	typealias	Snapshot		=	[T]
	typealias	Transaction		=	CollectionTransaction<Int,T>
	typealias	OutgoingSignal		=	StateSignal<Snapshot,Transaction>

	///

	public init(_ snapshot: Snapshot) {
		_snapshot	=	snapshot
	}
	public var snapshot: Snapshot {
		get {
			return	_snapshot
		}
		set(v) {
			_snapshot	=	v
		}
	}
	public func apply(transaction: Transaction) {
		_relay.cast(StateSignal.willEnd(_snapshot, by: transaction))
		Algorithms.apply(transaction, to: &_snapshot)
		_relay.cast(StateSignal.didBegin(_snapshot, by: transaction))
	}
	public func register(identifier: ObjectIdentifier, handler: OutgoingSignal->()) {
		_relay.register(identifier, handler: handler)
		_relay.cast(StateSignal.didBegin(_snapshot, by: nil))
	}
	public func deregister(identifier: ObjectIdentifier) {
		_relay.cast(StateSignal.willEnd(_snapshot, by: nil))
		_relay.deregister(identifier)
	}
	public func register<S : SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		_relay.register(s)
		_relay.cast(StateSignal.didBegin(_snapshot, by: nil))
	}
	public func deregister<S : SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		_relay.cast(StateSignal.willEnd(_snapshot, by: nil))
		_relay.deregister(s)
	}


	///

	private var	_snapshot	=	Snapshot()
	private let	_relay		=	Relay<OutgoingSignal>()
}
extension ArrayStorage: EditableArray, CollectionType, SequenceType {
	public var count: Int {
		get {
			return	_snapshot.count
		}
	}
	public var startIndex: Snapshot.Index {
		get {
			return	_snapshot.startIndex
		}
	}
	public var endIndex: Snapshot.Index {
		get {
			return	_snapshot.endIndex
		}
	}
	public func generate() -> Snapshot.Generator {
		return	_snapshot.generate()
	}

	///

	public subscript(index: Int) -> Snapshot.Element {
		get {
			return	_snapshot[index]
		}
		set(v) {
			let	old	=	_snapshot[index]
			let	new	=	v
			let	tran	=	CollectionTransaction([(index, old, new)])
			apply(tran)
		}
	}

	public subscript(subRange: Range<Int>) -> ArraySlice<T> {
		get {
			return	_snapshot[subRange]
		}
	}

	///

	public func insert(newElement: T, atIndex index: Int) {
		let	tran	=	CollectionTransaction([(index, nil, newElement)])
		apply(tran)
	}
	public func removeAtIndex(index: Int) {
		let	old	=	_snapshot[index]
		let	tran	=	CollectionTransaction([(index, old, nil)])
		apply(tran)
	}


	public func append(newElement: T) {
		let	index	=	_snapshot.count
		let	tran	=	CollectionTransaction([(index, past: nil, future: newElement)])
		apply(tran)
	}

	public func extend<S : SequenceType where S.Generator.Element == T>(newElements: S) {
		var	idx	=	_snapshot.count
		var	muts	=	Array<CollectionTransaction<Int,T>.Mutation>()
		for e in newElements {
			idx++
			muts.append((idx, nil, e))
		}
		let	tran	=	CollectionTransaction(muts)
		apply(tran)
	}
	public func removeLast() -> T {
		let	index	=	_snapshot.count - 1
		let	value	=	_snapshot.last!
		let	tran	=	CollectionTransaction([(index, value, nil)])
		apply(tran)
		return	value
	}

	public func removeAll() {
		var	muts	=	Array<CollectionTransaction<Int,T>.Mutation>()
		for i in reverse(0..<_snapshot.count) {
			let	old	=	_snapshot[i]
			muts.append((i, old, nil))
		}
		let	tran	=	CollectionTransaction(muts)
		apply(tran)
	}

	public func join<S : SequenceType where S.Generator.Element == Array<T>>(elements: S) -> [T] {
		return	_snapshot.join(elements)
	}

}



















