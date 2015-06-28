//
//  DictionaryMonitor.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/26.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class DictionaryMonitor<K: Hashable, V>: CollectionMonitorType {
	public var didInitiate: (()->())?
	public var willTerminate: (()->())?
	public var willApply: (CollectionTransaction<K,V>->())?
	public var didApply: (CollectionTransaction<K,V>->())?
	public var willEnd: (Dictionary<K,V>->())?
	public var didBegin: (Dictionary<K,V>->())?
	
	///
	
	private func _route(signal: CollectionSignal<Dictionary<K,V>,K,V>) {
		routeSignalToCollectionMonitor(signal, self)
	}
}
extension DictionaryChannel {
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
extension DictionaryFilteringDictionaryStorage {
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













