////
////  ExistenceMonitor.swift
////  SignalGraph
////
////  Created by Hoon H. on 2015/06/28.
////  Copyright (c) 2015 Eonil. All rights reserved.
////
//
/////	Provides existence based notifications.
/////
/////	This monitor simplifies mutations as series of `didAdd`/`willRemove` event pair.
/////	This works for each value or elements (of a collection) in the storage.
/////	Use this monitor if you don't want to care about binding sessions or transaction details.
/////
/////	Deduplication
/////	-------------
/////	This monitor performs deduplication on transaction before sending notifications. See
/////	this example. Assume this as mutations of a dictionary signal.
/////
/////		(111, nil, "A")
/////		(111, "A", nil)
/////		(111, nil, "A")
/////		(111, "A", nil)
/////		(111, nil, "A")
/////		(111, "A", nil)
/////
/////	If you apply this transaction, none of `didAdd` or `willRemove` will be called because
/////	nothing will be added or removed in the final result when compared to original dictionary.
/////
/////	For array monitors, deduplication may decrease performance dramatically.
/////	And you need to follow these special rules to keep best performance.
/////
/////	-	Place mutation command in this order: delete, update and insert.
/////	-	Sort delete command in descending order.
/////	-	Sort insert command in ascending order.
/////	-	Make sure that all indexes in a delete/update/insert partition are unique.
/////
/////	In the best case, deduplication can be completely avoided. (O(N))
/////	Otheriwse very expensive deduplication process will be performed. (roughly up to O(N^2))
/////
/////	All methods of all sotrage classes defined in this library follows the rules, so you don't
/////	need to worry anything unless you compose transaction mutation commands yourself.
/////
//public protocol ExistenceMonitorType: SensitiveStationType {
//	typealias	Entry
//
//	///	Notified when a new value/element has been added.
//	///	At the time of calling, the value/element is already on the soure storage.
//	var didAdd: ((Entry)->())? { get set }
//
//	///	Notified when an existing value/element is going to removed.
//	///	At the time of calling, the value/element is still on the soure storage.
//	var willRemove: ((Entry)->())? { get set }
//}
//
//public class ValueExistenceMonitor<T>: ExistenceMonitorType {
//	public typealias	Signal		=	StateSignal<T,ValueTransaction<T>>
//
//	public var didAdd: ((T)->())?
//	public var willRemove: ((T)->())?
//
//	public func cast(signal: Signal) {
//		MonitoringAlgorithms.route(signal, to: self)
//	}
//}
//
////public class SetExistenceMonitor<T: Hashable>: ExistenceMonitorType {
////	public typealias	Signal		=	SetStorage<T>.Signal
////
////	public var didAdd: ((T,())->())?
////	public var willRemove: ((T,())->())?
////
////	public func cast(signal: Signal) {
////		MonitoringAlgorithms.route(signal, to: self)
////	}
////}
//
////	Not ready yet.
////public class ArrayExistenceMonitor<T>: ExistenceMonitorType {
////	public typealias	Signal		=	ArrayStorage<T>.Signal
////
////	public var didAdd: ((Int,T)->())?
////	public var willRemove: ((Int,T)->())?
////
////	public func cast(signal: Signal) {
////		MonitoringAlgorithms.route(signal, to: self)
////	}
////}
//
////public class DictionaryExistenceMonitor<K: Hashable, V>: ExistenceMonitorType {
////	public typealias	Signal		=	DictionaryStorage<K,V>.Signal
////
////	public var didAdd: ((K,V)->())?
////	public var willRemove: ((K,V)->())?
////
////	public func cast(signal: Signal) {
////		MonitoringAlgorithms.route(signal, to: self)
////	}
////}
//
//
