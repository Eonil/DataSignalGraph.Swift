////
////  CollectionMonitor.swift
////  SG4
////
////  Created by Hoon H. on 2015/06/28.
////  Copyright (c) 2015 Eonil. All rights reserved.
////
//
//public class CollectionTimingMonitor<S: CollectionType, K: Hashable,V>: CollectionTimingMonitorType {
//
//	public var didInitiate: (()->())?
//	public var willTerminate: (()->())?
//	public var willApply: (CollectionTransaction<K,V>->())?
//	public var didApply: (CollectionTransaction<K,V>->())?
//	public var willEnd: (S->())?
//	public var didBegin: (S->())?
//
//	public var didAdd: (V->())?
//	public var willRemove: (V->())?
//
//	public func cast(signal: StateSignal<S,CollectionTransaction<K,V>>) {
//		_route(signal)
//	}
//
//	///
//
//	private func _route(signal: StateSignal<S,CollectionTransaction<K,V>>) {
//		routeSignalToCollectionMonitor(signal, self)
//	}
//}
//
//public class SetTimingMonitor<T: Hashable>: CollectionTimingMonitor<Set<T>,T,()> {
//	public override init() {
//	}
//}
//public class ArrayTimingMonitor<T>: CollectionTimingMonitor<[T],Int,T> {
//	public override init() {
//	}
//}
//public class DictionaryTimingMonitor<K: Hashable, V>: CollectionTimingMonitor<[K:V],K,V> {
//	public override init() {
//	}
//}
//
//
//
//
//
//
