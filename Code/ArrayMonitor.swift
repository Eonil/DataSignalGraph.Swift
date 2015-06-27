//
//  ArrayMonitor.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/26.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class ArrayMonitor<T>: CollectionMonitorType {
	public var didInitiate: (()->())?
	public var willTerminate: (()->())?
	public var willApply: (CollectionTransaction<Int,T>->())?
	public var didApply: (CollectionTransaction<Int,T>->())?
	public var willEnd: (Array<T>->())?
	public var didBegin: (Array<T>->())?
	
	///
	
	private func _route(signal: CollectionSignal<Array<T>,Int,T>) {
		routeSignalToCollectionMonitor(signal, self)
	}
}
extension ArrayStorage {
	///	Please note that channel does not keep a strong reference
	///	to monitors. You're responsible to keep them alive while
	///	they're attached to a channel.
	public func register(monitor: ArrayMonitor<T>) {
		register(ObjectIdentifier(monitor)) { [weak monitor] in monitor!._route($0) }
	}
	public func deregister(monitor: ArrayMonitor<T>) {
		deregister(ObjectIdentifier(monitor))
	}
}
extension ArrayMappingArrayStorage {
	///	Please note that channel does not keep a strong reference
	///	to monitors. You're responsible to keep them alive while
	///	they're attached to a channel.
	public func register(monitor: ArrayMonitor<U>) {
		register(ObjectIdentifier(monitor)) { [weak monitor] in monitor!._route($0) }
	}
	public func deregister(monitor: ArrayMonitor<U>) {
		deregister(ObjectIdentifier(monitor))
	}
}
extension DictionarySortingArrayStorage {
	///	Please note that channel does not keep a strong reference
	///	to monitors. You're responsible to keep them alive while
	///	they're attached to a channel.
	public func register(monitor: ArrayMonitor<(K,V)>) {
		register(ObjectIdentifier(monitor)) { [weak monitor] in monitor!._route($0) }
	}
	public func deregister(monitor: ArrayMonitor<(K,V)>) {
		deregister(ObjectIdentifier(monitor))
	}
}













