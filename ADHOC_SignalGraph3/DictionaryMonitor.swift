//
//  DictionaryMonitor.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/26.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class DictionaryMonitor<K: Hashable, V>: CollectionMonitorType {
	///	Monitoring session has been just started.
	public var didInitiate: (()->())?
	
	///	Monitoring session has been just ended.
	public var willTerminate: (()->())?
	
	///	A transaction is about to be applied.
	public var willApply: (CollectionTransaction<K,V>->())?
	
	///	A transaction has been applied.
	public var didApply: (CollectionTransaction<K,V>->())?
	
	///	A state is about to be ended.
	public var willEnd: (Dictionary<K,V>->())?
	
	///	A state has been started.
	public var didBegin: (Dictionary<K,V>->())?
	
	///
	
	private func _route(signal: CollectionSignal<Dictionary<K,V>,K,V>) {
		routeSignalToCollectionMonitor(signal, self)
	}
}
extension DictionaryStorage {
	///	Please note that channel does not keep a strong reference
	///	to monitors. You're responsible to keep them alive while
	///	they're attached to a channel.
	public func register(monitor: DictionaryMonitor<K,V>) {
		register(ObjectIdentifier(monitor)) { [weak monitor] in monitor!._route($0) }
	}
	public func deregister(monitor: DictionaryMonitor<K,V>) {
		deregister(ObjectIdentifier(monitor))
	}
}













