//
//  CollectionMonitorType.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/26.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

///	Provides decomposed event handler slots for `CollectionSignal`.
///	This is provided only for you convenience. A regular way to
///	handle a signal is using `SignalMonitor`.
///
///	**WARNING**
///	Calling orders between event handles triggered by single signal
///	are undefined. DO NOT depend on calling order. The only guarantee
///	is this.
///
///	-	`didInitiate`, `didApply`, `didBegin` will occur at timing
///		of `DidBegin` signal.
///
///	-	`willTerminate`, `willApply`, `willEnd` will occur at timing
///		of `WillEnd` signal.
///
public protocol CollectionMonitorType {
	typealias	StateSnapshot	:	CollectionType
	typealias	MutationKey	:	Hashable
	typealias	MutationValue
	
	///	Monitoring session has been just started.
	var didInitiate: (()->())? { get set }
	
	///	Monitoring session has been just ended.
	var willTerminate: (()->())? { get set }
	
	///	A transaction is about to be applied.
	var willApply: (CollectionTransaction<MutationKey,MutationValue>->())? { get set }
	
	///	A transaction has been applied.
	var didApply: (CollectionTransaction<MutationKey,MutationValue>->())? { get set }
	
	///	A state is about to be ended.
	var willEnd: (StateSnapshot->())? { get set }
	
	///	A state has been started.
	var didBegin: (StateSnapshot->())? { get set }
}

///	**WARNING**
///	Calling orders between event handles triggered by single signal
///	are undefined. DO NOT depend on calling order.
internal func routeSignalToCollectionMonitor<M: CollectionMonitorType>(signal: CollectionSignal<M.StateSnapshot, M.MutationKey, M.MutationValue>, monitor: M) {
	switch signal {
	case .DidBegin(let state, let by):
		switch by {
		case nil:
			monitor.didInitiate?()
		case _:
			monitor.didApply?(by!)
		}
		monitor.didBegin?(state())
		
	case .WillEnd(let state, let by):
		monitor.willEnd?(state())
		switch by {
		case _:
			monitor.willApply?(by!)
		case nil:
			monitor.willTerminate?()
		}
	}
}