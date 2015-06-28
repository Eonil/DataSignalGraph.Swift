//
//  CollectionMonitor.swift
//  SG4
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class CollectionMonitor<S: CollectionType, K: Hashable,V>: CollectionMonitorType {

	public var didInitiate: (()->())?
	public var willTerminate: (()->())?
	public var willApply: (CollectionTransaction<K,V>->())?
	public var didApply: (CollectionTransaction<K,V>->())?
	public var willEnd: (S->())?
	public var didBegin: (S->())?

	public func cast(signal: StateSignal<S,CollectionTransaction<K,V>>) {
		_route(signal)
	}

	///

	private func _route(signal: StateSignal<S,CollectionTransaction<K,V>>) {
		routeSignalToCollectionMonitor(signal, self)
	}
}

public class SetMonitor<T: Hashable>: CollectionMonitor<Set<T>,T,()> {
}
public class ArrayMonitor<T>: CollectionMonitor<[T],Int,T> {
}
public class DictionaryMonitor<K: Hashable, V>: CollectionMonitor<[K:V],K,V> {
}






