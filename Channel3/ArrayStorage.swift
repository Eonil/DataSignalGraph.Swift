//
//  ArrayStorage.swift
//  Channel3
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
	
	internal(set) var	state: [T] = []
	
	public var emitter: SignalEmitter<ArraySignal<T>> {
		get {
			return	dispatcher
		}
	}
	
	////
	
	private init() {
	}
	
	private let	dispatcher	=	SignalDispatcher<ArraySignal<T>>()
}




///	A storage that provides indirect signal based mutator.
///
///	Collection containers cannot have non-empty initial state because
///	it's hard to guarantee state integrity if there are many mutators.
///	Always Having empty initial state will make everything a lot simpler.
public class ArrayReplication<T>: ArrayStorage<T>, ReplicationType {
	
	public override init() {
		super.init()
		monitor.handler	=	{ [weak self] s in
			self!.state.apply(s)
			self!.dispatcher.signal(s)
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






/////	Provides mutation signal generator in `Array`-like interface.
//public final class ArrayEditor<T> {
//	public var emitter: SignalEmitter<ArraySignal<T>> {
//		get {
//			return	dispatcher
//		}
//	}
//	
//	func replaceRange<C : CollectionType where C.Generator.Element == T>(subRange: Range<Int>, with newElements: C) {
//		removeRange(subRange)
//		splice(newElements, atIndex: subRange.startIndex)
//	}
//	func splice<S : CollectionType where S.Generator.Element == T>(newElements: S, atIndex i: Int) {
//		typealias	M	=	CollectionTransaction<Int,T>.Mutation
//		var	ms	=	[] as [M]
//		var	c	=	i
//		for e in newElements {
//			let	m	=	(c,nil,e) as M
//			ms.append(m)
//			c++
//		}
//		let	t	=	CollectionTransaction(mutations: ms)
//		let	s	=	ArraySignal.Transition(transaction: t)
//		dispatcher.signal(s)
//	}
//	func removeRange(subRange: Range<Int>) {
//		typealias	M	=	CollectionTransaction<Int,T>.Mutation
//		map(reverse(subRange)) { M($0, nil, nil) }
//		for i in reverse(subRange) {
//			
//		}
//	}
//	
//	////
//	
//	private let	dispatcher	=	SignalDispatcher<ArraySignal<T>>()
//}













/////	Generates array mutation signals using `Array`-like interfaces.
/////	This is write-only, and you cannot read anything from this.
//public struct ArrayEditor<T> {
//	private let	dispatcher	=	SignalDispatcher<ArraySignal<T>>()
//	private var	count		=	0
//	
//	init() {
//	}
//	public var emitter: SignalEmitter<ArraySignal<T>> {
//		get {
//			return	dispatcher
//		}
//	}
//	public mutating func append(v: T) {
//		let	t	=	CollectionTransaction<Int, T>.insert((key: count, value: v))
//		let	s	=	ArraySignal.Transition(transaction: t)
//		dispatcher.signal(s)
//		count++
//	}
//	public mutating func extent<C: CollectionType where C.Generator.Element == T>(vs: C) {
//		var	c	=	count
//		let	vs1	=	map(vs) { (v: T)->(key: Int, value: T) in
//			let	p	=	(c,v)
//			c++
//			return	p
//		}
//		CollectionTransaction.insert(vs1)
//		count	=	c
//	}
//	public mutating func insert() {
//	}
//	public mutating func removeAt() {
//	}
//	public subscript(index: Int) -> T {
//		@availability(*,unavailable)
//		get {
//			fatalError("You cannot read from this object.")
//		}
//		set(v) {
//		}
//	}
//}

















