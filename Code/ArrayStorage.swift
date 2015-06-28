//
//  ArrayStorage.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/26.
//  Copyright (c) 2015 Eonil. All rights reserved.
//



public class ArrayStorage<T>: CollectionTransactionApplicable {
	public typealias	Signal		=	CollectionSignal<Array<T>,Int,T>
	
	///
	
	public init(_ snapshot: [T]) {
		_snapshot	=	snapshot
		_sigch.owner	=	self
	}
	public var snapshot: Array<T> {
		get {
			return	_snapshot
		}
		set(v) {
			_castWillEnd(by: _endSnapshotTransaction())
			_snapshot	=	v
			_castDidBegin(by: _beginSnapshotTransaction())
		}
	}
	public var channel: ArrayChannel<T> {
		get {
			return	_sigch
		}
	}
	
	public func apply(transaction: Signal.Transaction) {
		_castWillEnd(by: transaction)
		_snapshot.apply(transaction)		//	Must apply through `_snapshot` directly to avoid duplicated signal dispatch.
		_castDidBegin(by: transaction)
	}

	///
	
	private let	_sigch		=	ArrayChannel<T>()
	private var	_snapshot	=	Array<T>()
	
	private func _castDidBegin(by transaction: Signal.Transaction?) {
		_sigch.cast(Signal.DidBegin(state: { [weak self] in self!.snapshot}, by: transaction))
	}
	private func _castWillEnd(by transaction: Signal.Transaction?) {
		_sigch.cast(Signal.WillEnd(state: { [weak self] in self!.snapshot}, by: transaction))
	}
	
	private func _beginSnapshotTransaction() -> Signal.Transaction {
		let	muts	=	map(enumerate(snapshot), { Signal.Transaction.Mutation($0, nil, $1) })
		return	Signal.Transaction(mutations: muts)
	}
	private func _endSnapshotTransaction() -> Signal.Transaction {
		let	muts	=	map(enumerate(snapshot), { Signal.Transaction.Mutation($0, $1, nil) })
		return	Signal.Transaction(mutations: muts)
	}
}
//	We can generalize this into single `CollectionChannel` with Swift 2.x features.
public class ArrayChannel<T>: SignalChannel<CollectionSignal<[T],Int,T>> {
	public override func register(identifier: ObjectIdentifier, handler: Signal -> ()) {
		super.register(identifier, handler: handler)
		owner!._castDidBegin(by: nil)
	}
	public override func deregister(identifier: ObjectIdentifier) {
		owner!._castWillEnd(by: nil)
		super.deregister(identifier)
	}

	///

	private weak var owner: ArrayStorage<T>?
}



extension ArrayStorage: SequenceType {
	public var count: Int {
		get {
			return	_snapshot.count
		}
	}
	public subscript(index: Int) -> T {
		get {
			return	_snapshot[index]
		}
		set(v) {
			let	old	=	_snapshot[index]
			let	new	=	v
			let	tran	=	CollectionTransaction(mutations: [(index, old, new)])
			apply(tran)
		}
	}
	public subscript(subRange: Range<Int>) -> ArraySlice<T> {
		get {
			return	_snapshot[subRange]
		}
	}

	///

	public func generate() -> IndexingGenerator<[T]> {
		return	_snapshot.generate()
	}

	///
	
	public func insert(newElement: T, atIndex index: Int) {
		let	tran	=	CollectionTransaction(mutations: [(index, nil, newElement)])
		apply(tran)
	}
	public func removeAtIndex(index: Int) {
		let	old	=	_snapshot[index]
		let	tran	=	CollectionTransaction(mutations: [(index, old, nil)])
		apply(tran)
	}
	
	
	public func append(newElement: T) {
		let	index	=	_snapshot.count
		let	tran	=	CollectionTransaction(mutations: [(index, past: nil, future: newElement)])
		apply(tran)
	}
	
	public func extend<S : SequenceType where S.Generator.Element == T>(newElements: S) {
		var	idx	=	_snapshot.count
		var	muts	=	Array<CollectionTransaction<Int,T>.Mutation>()
		for e in newElements {
			idx++
			muts.append((idx, nil, e))
		}
		let	tran	=	CollectionTransaction(mutations: muts)
		apply(tran)
	}
	public func removeLast() -> T {
		let	index	=	_snapshot.count - 1
		let	value	=	_snapshot.last!
		let	tran	=	CollectionTransaction(mutations: [(index, value, nil)])
		apply(tran)
		return	value
	}
	
	public func removeAll() {
		var	muts	=	Array<CollectionTransaction<Int,T>.Mutation>()
		for i in reverse(0..<_snapshot.count) {
			let	old	=	_snapshot[i]
			muts.append((i, old, nil))
		}
		let	tran	=	CollectionTransaction(mutations: muts)
		apply(tran)
	}
	
	public func join<S : SequenceType where S.Generator.Element == Array<T>>(elements: S) -> [T] {
		return	_snapshot.join(elements)
	}
	
}







