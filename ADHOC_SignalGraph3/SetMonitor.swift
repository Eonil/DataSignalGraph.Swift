//
//  SetMonitor.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/26.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class SetMonitor<T: Hashable>: CollectionMonitorType {
	///	Monitoring session has been just started.
	public var didInitiate: (()->())?
	
	///	Monitoring session has been just ended.
	public var willTerminate: (()->())?
	
	///	A transaction is about to be applied.
	public var willApply: (CollectionTransaction<T,()>->())?
	
	///	A transaction has been applied.
	public var didApply: (CollectionTransaction<T,()>->())?
	
	///	A state is about to be ended.
	public var willEnd: (Set<T>->())?
	
	///	A state has been started.
	public var didBegin: (Set<T>->())?
	
	///
	
	private func _route(signal: CollectionSignal<Set<T>,T,()>) {
		routeSignalToCollectionMonitor(signal, self)
	}
}
extension SetStorage {
	///	Please note that channel does not keep a strong reference
	///	to monitors. You're responsible to keep them alive while
	///	they're attached to a channel.
	public func register(monitor: SetMonitor<T>) {
		register(ObjectIdentifier(monitor)) { [weak monitor] in monitor!._route($0) }
	}
	public func deregister(monitor: SetMonitor<T>) {
		deregister(ObjectIdentifier(monitor))
	}
}


