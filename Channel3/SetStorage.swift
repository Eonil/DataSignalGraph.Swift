////
////  SetStorage.swift
////  Channel3
////
////  Created by Hoon H. on 2015/05/06.
////  Copyright (c) 2015 Eonil. All rights reserved.
////
//
//public class SetStorage<T: Hashable>: StorageType {
//	
//	public private(set) var	state: Set<T> = Set()
//	
//	public var emitter: SignalEmitter<SetSignal<T>> {
//		get {
//			return	dispatcher
//		}
//	}
//	
//	////
//	
//	private init() {
//	}
//	
//	private let	dispatcher	=	SignalDispatcher<SetSignal<T>>()
//}
//
/////	A storage that provides indirect signal based mutator.
/////
/////	Initial state of a state-container is undefined, and you should not access
/////	them while this contains is not bound to a signal source.
//public class SetReplication<T: Hashable>: SetStorage<T>, ReplicationType {
//	
//	public override init() {
//		super.init()
//		monitor.handler	=	{ [weak self] s in
//			self!.state.apply(s)
//			self!.dispatcher.signal(s)
//		}
//	}
//	
//	public var sensor: SignalSensor<SetSignal<T>> {
//		get {
//			return	monitor
//		}
//	}
//	
//	////
//	
//	private let	monitor		=	SignalMonitor<SetSignal<T>>({ _ in })
//}
//
//
//
//
//
//
//
//
