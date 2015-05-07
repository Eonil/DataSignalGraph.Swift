//
//  ValueStorage.swift
//  Channel3
//
//  Created by Hoon H. on 2015/05/05.
//  Copyright (c) 2015 Eonil. All rights reserved.
//





///	A read-only proxy view of a repository.
///
public class ValueStorage<T>: StorageType {
	public private(set) var state: T {
		didSet {
			dispatcher.signal(state)
		}
	}
	
	public var emitter: SignalEmitter<T> {
		get {
			return	dispatcher
		}
	}
	
	////
	
	private let	dispatcher	=	SignalDispatcher<T>()
	
	private init(_ state: T) {
		self.state	=	state
	}
}







///	A mutable storage. Mutation can be performed by receiving mutation 
///	signals. So the sensor is the only mutator.
///
public final class ValueReplication<T>: ValueStorage<T>, ReplicationType {
	public override init(_ state: T) {
		super.init(state)
		self.monitor.handler	=	{ [weak self] s in
			self!.state			=	s
		}
	}
	
	public var sensor: SignalSensor<T> {
		get {
			return	monitor
		}
	}
	
	////
	
	private let	monitor		=	SignalMonitor<T>({ _ in })
}












