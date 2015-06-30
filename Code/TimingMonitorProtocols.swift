//
//  MonitorProtocols.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/26.
//  Copyright (c) 2015 Eonil. All rights reserved.
//







public protocol ValueTimingMonitorType: SensitiveStationType {
	typealias	StateSnapshot

	///	A new state has begun by starting of monitoring session.
	var didInitiate: (()->())? { get set }

	///	Current state will be ended by ending of current monitoring session.
	var willTerminate: (()->())? { get set }

	///	A new state has begun by applicating a transaction.
	var didApply: (ValueTransaction<StateSnapshot>->())? { get set }

	///	Current state will be ended by applicating a new transaction.
	var willApply: (ValueTransaction<StateSnapshot>->())? { get set }

	///	A state has been started. You must already been notified the reason that
	///	triggered this state mutation.
	var didBegin: (StateSnapshot->())? { get set }

	///	A state is about to be ended. You will be notified the reason that will
	///	trigger this state mutation.
	var willEnd: (StateSnapshot->())? { get set }
}

internal func routeSignalToValueMonitor<M: ValueTimingMonitorType>(signal: StateSignal<M.StateSnapshot,ValueTransaction<M.StateSnapshot>>, monitor: M) {
	switch signal.timing {
	case .DidBegin:
		switch signal.by {
		case nil:
			monitor.didInitiate?()
		case _:
			monitor.didApply?(signal.by!)
		}
		monitor.didBegin?(signal.state)

	case .WillEnd:
		monitor.willEnd?(signal.state)
		switch signal.by {
		case nil:
			monitor.willTerminate?()
		case _:
			monitor.willApply?(signal.by!)
		}
	}
}










///	Provides decomposed event handler slots for `CollectionSignal`.
///	This is provided only for you convenience. A regular way to
///	handle a signal is using `SignalMonitor`.
///
///	How to Use
///	----------
///	Set handlers for `didBegin` and `willEnd` pair. Then you will be notified
///	properly for almost cases.
///	Set handlers for `didInitiate` and `willTerminate` pair if you need to 
///	perform special initiation/termination oeprations when registering/
///	deregistering monitors.
///	Set handlers for `willApply` and `didApply` pair to do something 
///	specifically for a transaction.
///	If this feels a little complex, please see `CollectionSignal` type. That 
///	should be simpler and easier to understand.
///
///	Notification Order
///	------------------
///	Semantically, notifiation order for single signal cannot be 
///	defined. But we need them in practice. So this monitor just defines
///	them only for your convenience.
///	Please note that this order is defined only for this monitor, and
///	not guaranteed for overall this library.
///
///	Notification will occur in this order.
///
///	-	When registering/deregistering a monitor.
///
///		1.	didInitiate
///		2.	didBegin
///
///		3.	willEnd
///		4.	willTerminate
///
///	-	When applying a transaction.
///
///		1.	didApply (with prior transaction that triggered current state)
///		2.	didBegin
///		
///		3.	willEnd
///		4.	willApply (with next transaction that will trigger new state)
///
///		Please note that this involves two different transactions.
///		Then, for single transaction, notification order can be though in this way.
///	
///		1.	willEnd
///		2.	willApply
///
///		>	(transaction application done at here)
///
///		3.	didApply
///		4.	didBegin
///
public protocol CollectionTimingMonitorType: SensitiveStationType {
	typealias	StateSnapshot	:	CollectionType
	typealias	MutationKey	:	Hashable
	typealias	MutationValue
	
	///	A new state has begun by starting of monitoring session.
	var didInitiate: (()->())? { get set }
	
	///	Current state will be ended by ending of current monitoring session.
	var willTerminate: (()->())? { get set }
	
	///	A new state has begun by applicating a transaction.
	var didApply: (CollectionTransaction<MutationKey,MutationValue>->())? { get set }
	
	///	Current state will be ended by applicating a new transaction.
	var willApply: (CollectionTransaction<MutationKey,MutationValue>->())? { get set }
	
	///	A state has been started. You must already been notified the reason that
	///	triggered this state mutation.
	var didBegin: (StateSnapshot->())? { get set }

	///	A state is about to be ended. You will be notified the reason that will
	///	trigger this state mutation.
	var willEnd: (StateSnapshot->())? { get set }
}

internal func routeSignalToCollectionMonitor<M: CollectionTimingMonitorType>(signal: StateSignal<M.StateSnapshot,CollectionTransaction<M.MutationKey, M.MutationValue>>, monitor: M) {
	switch signal.timing {
	case .DidBegin:
		switch signal.by {
		case nil:
			monitor.didInitiate?()
		case _:
			monitor.didApply?(signal.by!)
		}
		monitor.didBegin?(signal.state)
		
	case .WillEnd:
		monitor.willEnd?(signal.state)
		switch signal.by {
		case nil:
			monitor.willTerminate?()
		case _:
			monitor.willApply?(signal.by!)
		}
	}
}



