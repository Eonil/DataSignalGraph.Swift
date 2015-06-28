//
//  ExistenceMonitor.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

///	Provides existence based notifications.
///
///	This monitor simplifies mutations as series of `didAdd`/`willRemove` event pair.
///	This works for each value or elements (of a collection) in the storage.
///	Use this monitor if you don't want to care about binding sessions or transaction details.
///
///	This monitor is simple, but fundamentally inefficient because all notifications for each
///	entry are split and notified as separated function calls. This prevents batched UI update.
///	You must deal with bare state-signals to get such batched update.
///
public protocol ExistenceMonitorType: SensitiveStationType {
	typealias	Entry

	///	Notified when a new value/element has been added.
	///	At the time of calling, the value/element is already on the soure storage.
	var didAdd: ((Entry)->())? { get set }

	///	Notified when an existing value/element is going to removed.
	///	At the time of calling, the value/element is still on the soure storage.
	var willRemove: ((Entry)->())? { get set }
}

public class ValueExistenceMonitor<T>: ExistenceMonitorType {
	public typealias	Signal		=	ValueStorage<T>.Signal

	public var didAdd: ((T)->())?
	public var willRemove: ((T)->())?

	public func cast(signal: Signal) {
		MonitoringAlgorithms.route(signal, to: self)
	}
}

public class SetExistenceMonitor<T: Hashable>: ExistenceMonitorType {
	public typealias	Signal		=	SetStorage<T>.Signal

	public var didAdd: ((T,())->())?
	public var willRemove: ((T,())->())?

	public func cast(signal: Signal) {
		MonitoringAlgorithms.route(signal, to: self)
	}
}

public class ArrayExistenceMonitor<T>: ExistenceMonitorType {
	public typealias	Signal		=	ArrayStorage<T>.Signal

	public var didAdd: ((Int,T)->())?
	public var willRemove: ((Int,T)->())?

	public func cast(signal: Signal) {
		MonitoringAlgorithms.route(signal, to: self)
	}
}

public class DictionaryExistenceMonitor<K: Hashable, V>: ExistenceMonitorType {
	public typealias	Signal		=	DictionaryStorage<K,V>.Signal

	public var didAdd: ((K,V)->())?
	public var willRemove: ((K,V)->())?

	public func cast(signal: Signal) {
		MonitoringAlgorithms.route(signal, to: self)
	}
}


