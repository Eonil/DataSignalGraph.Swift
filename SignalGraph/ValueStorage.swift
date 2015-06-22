////
////  ValueStorage.swift
////  SG2
////
////  Created by Hoon H. on 2015/06/20.
////  Copyright © 2015 Eonil. All rights reserved.
////
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
//
//
//
//
//class ValueStorage<T>: StateSignalChannel<ValueStorage<T>>, StateStorageType {
//	typealias	Snapshot	=	T
//	typealias	Transaction	=	ValueTransaction<T>
//	typealias	Signal		=	StateSignal<ValueStorage<T>>
//	
//	init(_ snapshot: T) {
//		_snapshot	=	snapshot
//	}
//	var snapshot: T {
//		get {
//			return	_snapshot
//		}
//		set(v) {
//			let	old	=	_snapshot
//			let	new	=	v
//			let	tran	=	Transaction.Reset(new)
//			let	reason	=	Signal.Reason.StateMutationTransaction(transaction: tran)
//			_dispatcher.transfer(.WillApply(transaction: tran))
//			_dispatcher.transfer(.WillEnd(state: old, by: reason))
//			_snapshot	=	v
//			_dispatcher.transfer(.DidBegin(state: new, by: reason))
//			_dispatcher.transfer(.DidApply(transaction: tran))
//		}
//	}
////
////	func register<M: SignalMonitor<Signal>>(monitor: M) {
////		_dispatcher.register(monitor)
////	}
////	func deregister<M: SignalMonitor<Signal>>(monitor: M) {
////		_dispatcher.deregister(monitor)
////	}
////	
////	///
////	
////	private var	_snapshot	:	T
////	private let	_dispatcher	=	StateSignalDispatcher<ValueStorage<T>>()
//}
//
//enum ValueTransaction<T> {
//	case Reset(T)
//}
//
//class ValueMonitor<T>: StateSignalMonitor<ValueStorage<T>> {
//	
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
//
//
//
//
//
////public enum ValueSignal<T> {
////	case Snapshot(T)
////}
////public class ValueStorage<T>: StorageType {
////	public typealias	State		=	T
////	public typealias	Signal		=	ValueSignal<T>
////	public typealias	Monitor		=	StateMonitor<ValueStorage<T>>
////	
////	public init(_ snapshot: T) {
////		self.snapshot	=	snapshot
////	}
////	public var snapshot: T {
////		willSet {
////			_dispatcher.willApply(ValueSignal<T>.Snapshot(snapshot))
////		}
////		didSet {
////			_dispatcher.didApply(ValueSignal<T>.Snapshot(snapshot))
////		}
////	}
////	
////	public func register(monitor: Monitor) {
////		_dispatcher.register(monitor)
////		_dispatcher.willApply(ValueSignal<T>.Snapshot(snapshot))
////		_dispatcher.didApply(ValueSignal<T>.Snapshot(snapshot))
////	}
////	public func deregister(monitor: Monitor) {
////		_dispatcher.willApply(ValueSignal<T>.Snapshot(snapshot))
////		_dispatcher.didApply(ValueSignal<T>.Snapshot(snapshot))
////		_dispatcher.deregister(monitor)
////	}
////	
////	///
////	
////	private let	_dispatcher	=	StateDispatcher<ValueStorage<T>>()
////}
////public class ValueMonitor<T>: StateMonitor<ValueStorage<T>> {
////}
////
