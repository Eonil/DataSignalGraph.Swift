//
//  ArrayStorageEditor.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/05/08.
//  Copyright (c) 2015 Eonil. All rights reserved.
//



///	A zero-cost wrapper around a `ReplicatingArrayStorage`
///	which provides array-like interface.
///
///	This produces and sends `ArraySignal` to `origin` to
///	mutate it. Mutator methods also returns appropriate 
///	values.
///
public struct ArrayStorageEditor<T>: SequenceType {
	
	unowned let	storage: ReplicatingArrayStorage<T>
	
	public init(_ storage: ReplicatingArrayStorage<T>) {
		self.storage	=	storage
	}
	
	////
	
	public var startIndex: Array<T>.Index {
		get {
			return	storage.state.startIndex
		}
	}
	public var endIndex: Array<T>.Index {
		get {
			return	storage.state.endIndex
		}
	}
	public var count: Int {
		get {
			return	storage.state.count
		}
	}
	public subscript(i: Int) -> T {
		get {
			return	storage.state[i]
		}
		set(v) {
			replaceRange(i..<i.successor(), with: [v])
		}
	}
	
	public func generate() -> Array<T>.Generator {
		return	storage.state.generate()
	}
	
	public mutating func append(v: T) {
		insert(v, atIndex: count)
	}
	public mutating func extend<S: SequenceType where S.Generator.Element == T>(vs: S) {
		//	TODO:	Review cost of making the array...
		//			Would it require enumeration of all elements?
		splice(Array(vs), atIndex: count)
	}
	public mutating func removeLast() -> T {
		let	v	=	storage.state.last!
		removeAtIndex(count-1)
		return	v
	}
	public mutating func insert(v: T, atIndex i: Int) {
		splice([v], atIndex: i)
	}
	public mutating func removeAtIndex(i: Int) -> T {
		let	v	=	storage.state[i]
		removeRange(i..<i.successor())
		return	v
	}
	public mutating func removeAll() {
		storage.sensor.signal(ArraySignal.Termination(snapshot: storage.state))
		storage.sensor.signal(ArraySignal.Initiation(snapshot: []))
	}
	
	public mutating func replaceRange<C : CollectionType where C.Generator.Element == T>(subRange: Range<Int>, with newElements: C) {
		let	ms0	=	deleteRangeMutations(subRange)
		let	ms1	=	insertSequenceMutations(newElements, at: subRange.startIndex)
		dispatchMutations(ms0 + ms1)
	}
	public mutating func splice<S : CollectionType where S.Generator.Element == T>(newElements: S, atIndex i: Int) {
		if i == 0 && count == 0 {
			storage.sensor.signal(ArraySignal.Termination(snapshot: []))
			storage.sensor.signal(ArraySignal.Initiation(snapshot: Array(newElements)))
		} else {
			dispatchMutations(insertSequenceMutations(newElements, at: i))
		}
	}
	public mutating func removeRange(subRange: Range<Int>) {
		if subRange.startIndex == 0 && subRange.endIndex == count {
			removeAll()
		} else {
			dispatchMutations(deleteRangeMutations(subRange))
		}
	}
	
	////
	
	private typealias	M	=	CollectionTransaction<Int,T>.Mutation
	
	private func insertMutation(i: Int, _ v: T) -> M {
		return	M(i, nil, v)
	}
	private func updateMutation(i: Int, _ v: T) -> M {
		return	M(i, self[i], v)
	}
	private func deleteMutation(i: Int) -> M {
		return	M(i, self[i], nil)
	}
	private func insertSequenceMutations<S: SequenceType where S.Generator.Element == T>(vs: S, at: Int) -> [M] {
		var	ms	=	[] as [M]
		var	c	=	at
		for v in vs {
			let	m	=	insertMutation(c, v)
			ms.append(m)
			c++
		}
		return	ms
	}
	private func updateSequenceMutations<S: SequenceType where S.Generator.Element == T>(vs: S, at: Int) -> [M] {
		var	ms	=	[] as [M]
		var	c	=	at
		for v in vs {
			let	m	=	updateMutation(c, v)
			ms.append(m)
			c++
		}
		return	ms
	}
	private func deleteRangeMutations(range: Range<Int>) -> [M] {
		var	ms	=	[] as [M]
		for i in range {
			let	m	=	deleteMutation(i)
			ms.append(m)
		}
		return	ms
	}
	private func dispatchMutations(ms: [M]) {
		let	t	=	CollectionTransaction(mutations: ms)
		let	s	=	ArraySignal.Transition(transaction: t)
		storage.sensor.signal(s)
	}
}











