//
//  ArrayStorage.swift
//  Channel3
//
//  Created by Hoon H. on 2015/05/05.
//  Copyright (c) 2015 Eonil. All rights reserved.
//





public class ArrayStorage<T>: StorageType {
	public typealias	Element	=	T
	
	public private(set) var	state: [T] = []
	
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




///	Collection containers cannot have non-empty initial state because
///	it's hard to guarantee state integrity if there are many mutators.
///	Always Having empty initial state will make everything a lot simpler.
public final class ArrayReplication<T>: ArrayStorage<T>, ReplicationType {
	
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
	
	public var editor: ArrayEditor<T> {
		get {
			return	ArrayEditor()
		}
	}
	
	////
	
	private let	monitor		=	SignalMonitor<ArraySignal<T>>({ _ in })
}

public struct ArrayEditor<T> {
	private let	dispatcher	=	SignalDispatcher<ArraySignal<T>>()
	private var	count		=	0
	
	init() {
	}
	public var emitter: SignalEmitter<ArraySignal<T>> {
		get {
			return	dispatcher
		}
	}
	public mutating func append(v: T) {
		let	t	=	CollectionTransaction<Int, T>.insert((key: count, value: v))
		let	s	=	ArraySignal.Transition(transaction: t)
		dispatcher.signal(s)
		count++
	}
	public mutating func extent<C: CollectionType where C.Generator.Element == T>(vs: C) {
		var	c	=	count
		let	vs1	=	map(vs) { (v: T)->(key: Int, value: T) in
			let	p	=	(c,v)
			c++
			return	p
		}
		CollectionTransaction.insert(vs1)
		count	=	c
	}
}

















