//
//  CollectionMonitor.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/04.
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
///	2.	willApply
///
///	Transaction does not trigger begin/end notification.
///	Because each mutation will trigger them. If a transaction
///	is empty with no mutation, then it means begin/end are 
///	happening.
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
///	one or more mutation signals that describe the transaction.
///
public class CollectionMonitor<S: CollectionType, K, V>: CollectionMonitorType, SensitiveStationType, StateCollectionSegmentMonitorType, StateSegmentMonitorType, SessionMonitorType, TransactionMonitorType, StateMonitorType {
	public typealias	Key		=	K
	public typealias	Value		=	V

	public typealias	Segment		=	(Key,Value)
	public typealias	Signal		=	StateSignal<S, CollectionTransaction<Key,Value>>
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
				let	m	=	m()
				switch m {
				case (_, nil, nil):	fatalError("Irrational combination.")
				case (_, nil, _):	didAdd?(m.segment, m.future!)
				case (_, _, nil):	break
				case (_, _, _):		didAdd?(m.segment, m.future!)
				}
				didBegin?(state())
			}

		case .WillEnd(let state, let by):
			switch by() {
			case .Mutation(let m):
				willEnd?(state())
				let	m	=	m()
				switch m {
				case (_, nil, nil):	fatalError("Irrational combination.")
				case (_, nil, _):	break
				case (_, _, nil):	willRemove?(m.segment, m.past!)
				case (_, _, _):		willRemove?(m.segment, m.past!)
				}
			case .Transaction(let t):
				willApply?(t())
			case .Session(let s):
				willEnd?(state())
				willTerminate?()
			}

		}
	}
}

public final class SetMonitor<T: Hashable>: CollectionMonitor<Set<T>,Set<T>,()> {
	public override init() {
	}
}
public final class ArrayMonitor<T>: CollectionMonitor<[T],Range<Int>,[T]> {
	public override init() {
	}
}
public final class DictionaryMonitor<K: Hashable,V>: CollectionMonitor<[K:V],K,V> {
	public override init() {
	}
}




