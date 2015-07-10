//
//  ValueMonitor.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/05.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

///	There's no defined order in session/transaction/mutation notifications.
///	Because they're semantically happen and practically sent all at once.
///	Anyway this monitor defines calling orders of them for your convenience.
///
///	Basically, cause of state beginning will be notified first, and new state last.
///	In reversed order for ending. Here's a proper table.
///
///	For sessions,
///
///	1.	didInitiate
///	2.	didBegin
///
///	3.	willEnd
///	4.	willTerminate
///
///	For transactions,
///
///	1.	didApply
///	2.	didBegin
///
///	3.	willEnd
///	4.	willApply
///
///	For mutations,
///
///	1.	didAdd
///	2.	didBegin
///
///	3.	willEnd
///	4.	willRemove
///
///	Please note that session and transaction signals are mutually exclusive, and
///	won't happen together, but a transaction signal will always be followed by
///	zero or more mutation signals that describe the transaction.
///
///	Segment
///	-------
///	As a value is conceptually an atomic state that cannot be divided into,
///	`ValueMonitor` treats a whole single value state as a segment.
///
public class ValueMonitor<T>: ValueMonitorType, SensitiveStationType, StateSegmentMonitorType, SessionMonitorType, TransactionMonitorType, StateMonitorType {
	public typealias	Segment		=	T
	public typealias	Signal		=	StateSignal<T, ValueTransaction<T>>
	public typealias	IncomingSignal	=	Signal

	public var		didInitiate	:	(()->())?
	public var		willTerminate	:	(()->())?

	public var		didApply	:	(Signal.Transaction->())?
	public var		willApply	:	(Signal.Transaction->())?

	public var		didBegin	:	(Signal.Snapshot->())?
	public var		willEnd		:	(Signal.Snapshot->())?

	public var		didAdd		:	(Segment->())?
	public var		willRemove	:	(Segment->())?
	
	public func cast(signal: Signal) {
		switch signal {

		case .DidBegin(let state, let by):
			switch by() {
			case .Session(let s):
				didInitiate?()
				didBegin?(state())
			case .Transaction(let t):
				didApply?(t())
			case .Mutation(let m):
				didAdd?(m().future)
				didBegin?(state())
			}

		case .WillEnd(let state, let by):
			switch by() {
			case .Mutation(let m):
				willEnd?(state())
				willRemove?(m().past)
			case .Transaction(let t):
				willApply?(t())
			case .Session(let s):
				willEnd?(state())
				willTerminate?()
			}

		}
	}
}



