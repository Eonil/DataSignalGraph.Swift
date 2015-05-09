////
////  ValueStorage.swift
////  Channel3
////
////  Created by Hoon H. on 2015/05/05.
////  Copyright (c) 2015 Eonil. All rights reserved.
////
//
//
//
//
//
/////	A read-only proxy view of a repository.
/////
//public class ValueStorage<T>: StorageType {
//	public var state: T {
//		get {
//			return	value!
//		}
//	}
//	
//	public var emitter: SignalEmitter<T> {
//		get {
//			return	dispatcher
//		}
//	}
//	
//	////
//	
//	private let	dispatcher	=	SignalDispatcher<ValueSignal<T>>()
//	
//	private init() {
//	}
//	
//	private var	value: T? {
//		didSet {
//			let	s	=	ValueSignal.ini
//			dispatcher.signal(state)
//		}
//	}
//}
//
//
//
//
//
//
//
/////	A mutable storage. Mutation can be performed by receiving mutation 
/////	signals. So the sensor is the only mutator.
/////
//public final class ValueReplication<T>: ValueStorage<T>, ReplicationType {
//	public override init() {
//		super.init()
//		self.monitor.handler	=	{ [weak self] s in
//			self!.value			=	s
//		}
//	}
//	
//	public var sensor: SignalSensor<ValueSignal<T>> {
//		get {
//			return	monitor
//		}
//	}
//	
//	////
//	
//	private let	monitor		=	SignalMonitor<ValueSignal<T>>({ _ in })
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
