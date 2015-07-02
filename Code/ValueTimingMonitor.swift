////
////  ValueMonitor.swift
////  SignalGraph
////
////  Created by Hoon H. on 2015/06/28.
////  Copyright (c) 2015 Eonil. All rights reserved.
////
//
//public class ValueTimingMonitor<T>: ValueTimingMonitorType {
//
//	public init() {
//	}
//
//	public var didInitiate: (()->())?
//	public var willTerminate: (()->())?
//	public var willApply: (ValueTransaction<T>->())?
//	public var didApply: (ValueTransaction<T>->())?
//	public var willEnd: (T->())?
//	public var didBegin: (T->())?
//
//	public func cast(signal: StateSignal<T,ValueTransaction<T>>) {
//		_route(signal)
//	}
//
//	///
//
//	private func _route(signal: StateSignal<T,ValueTransaction<T>>) {
//		routeSignalToValueMonitor(signal, self)
//	}
//}
//
//
//
//
