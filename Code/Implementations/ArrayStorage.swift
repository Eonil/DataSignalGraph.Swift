//
//  ArrayStorage.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/01.
//  Copyright © 2015 Eonil. All rights reserved.
//

///	This uses an array as a minimum mutation segment.
///	Single element mutation a bit less efficient, but it always does.
///	Multiple element mutation should be far more efficient.
///
public class ArrayStorage<T>: ArrayStorageType {
	public typealias	Element		=	T
	public typealias	Snapshot	=	[T]
	public typealias	Transaction	=	CollectionTransaction<Range<Int>,[T]>
	public typealias	OutgoingSignal	=	StateSignal<Snapshot, Transaction>

	public typealias	Signal		=	OutgoingSignal

	///

	public init(_ snapshot: [T]) {
		_snapshot	=	snapshot
	}
	deinit {
	}

	///

	public var snapshot: [T] {
		get {
			return	_snapshot
		}
		set(v) {
			apply(Transaction([
				(0..<count, _snapshot, nil),
				(0..<v.count, nil, v),
				]))
		}
	}
	public func apply(transaction: Transaction) {
		assert(_isApplying == false, "You cannot call `apply` until existing application to be finished.")
		_isApplying	=	true
		_cast(HOTFIX_StateSignalUtility.willEndStateByTransaction(_snapshot, transaction: transaction))
		for m in transaction.mutations {
			_cast(HOTFIX_StateSignalUtility.willEndStateByMutation(_snapshot, mutation: m))
			switch m {
			case (_,nil,nil):	fatalError()
			case (_,nil,_):		_snapshot.splice(m.future!, atIndex: m.segment.startIndex)
			case (_,_,nil):		_snapshot.removeRange(m.segment)
			case (_,_,_):		_snapshot.replaceRange(m.segment, with: m.future!)
			}
			_cast(HOTFIX_StateSignalUtility.didBeginStateByMutation(_snapshot, mutation: m))
		}
		_cast(HOTFIX_StateSignalUtility.didBeginStateByTransaction(_snapshot, transaction: transaction))
		_isApplying	=	false
	}
	public func register(identifier: ObjectIdentifier, handler: Signal->()) {
		_relay.register(identifier, handler: handler)
		handler(HOTFIX_StateSignalUtility.didBeginStateBySession(_snapshot))
	}
	public func deregister(identifier: ObjectIdentifier) {
		_relay.handlerForIdentifier(identifier)(HOTFIX_StateSignalUtility.willEndStateBySession(_snapshot))
		_relay.deregister(identifier)
	}
	public func register<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		register(ObjectIdentifier(s))	{ [weak s] in s!.cast($0) }
	}
	public func deregister<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		deregister(ObjectIdentifier(s))
	}
//	public func register<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal, S: StateSegmentMonitor>(s: S) {
//		_frequentRelay.register(ObjectIdentifier(s))	{ [weak s] in s!.cast($0) }
//		s.cast(HOTFIX_StateSignalUtility.didBeginStateBySession(_snapshot))
//	}
//	public func deregister<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal, S: StateSegmentMonitor>(s: S) {
//		s.cast(HOTFIX_StateSignalUtility.willEndStateBySession(_snapshot))
//		_frequentRelay.deregister(ObjectIdentifier(s))
//	}

	///

	private typealias	_Signal		=	Signal

	private let		_relay		=	Relay<Signal>()
	private var		_snapshot	:	[T]

	private var		_isApplying	=	false

	private func _cast(signal: Signal) {
		_relay.cast(signal)
	}
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
			let	tran	=	CollectionTransaction([(index...index, [old], [new])])
			apply(tran)
		}
	}

	public subscript(subRange: Range<Int>) -> ArraySlice<T> {
		get {
			return	_snapshot[subRange]
		}
	}

	public func join<S : SequenceType where S.Generator.Element == Array<T>>(elements: S) -> [T] {
		return	_snapshot.join(elements)
	}

	///

	public func insert(newElement: T, atIndex index: Int) {
		let	tran	=	CollectionTransaction([(index...index, nil, [newElement])])
		apply(tran)
	}
	public func removeAtIndex(index: Int) {
		let	old	=	_snapshot[index]
		let	tran	=	CollectionTransaction([(index...index, [old], nil)])
		apply(tran)
	}


	public func append(newElement: T) {
		let	index	=	_snapshot.count
		let	tran	=	CollectionTransaction([(index...index, past: nil, future: [newElement])])
		apply(tran)
	}

	public func extend<S : SequenceType where S.Generator.Element == T>(newElements: S) {
		let	es	=	Array(newElements)
		let	ran	=	_snapshot.count..<(_snapshot.count + es.count)
		let	tran	=	CollectionTransaction([(ran, nil, es)])
		apply(tran)
	}
	public func removeLast() -> T {
		let	index	=	_snapshot.count - 1
		let	value	=	_snapshot.last!
		let	tran	=	CollectionTransaction([(index...index, [value], nil)])
		apply(tran)
		return	value
	}

	public func removeAll() {
		let	tran	=	CollectionTransaction([(0..<_snapshot.count, _snapshot, nil)])
		apply(tran)
	}
}






private func _singleElementCollectionTransaction<T>(identity: Int, past: T?, future: T?) -> CollectionTransaction<Int,T> {
	return	CollectionTransaction([])
}
