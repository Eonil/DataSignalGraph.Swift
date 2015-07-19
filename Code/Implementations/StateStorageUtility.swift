//
//  StateStorageUtility.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/04.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

struct StateStorageUtility {

	///	Applies a transaction to a set snapshot and relays the transaction.
	static func apply<T: Hashable>(transaction: CollectionTransaction<Set<T>,()>, inout to snapshot: Set<T>, relay: Relay<TimingSignal<Set<T>,CollectionTransaction<Set<T>,()>>>) {
		relay.cast(HOTFIX_TimingSignalUtility.willEndStateByTransaction(snapshot, transaction: transaction))
		for m in transaction.mutations {
			relay.cast(HOTFIX_TimingSignalUtility.willEndStateByMutation(snapshot, mutation: m))
			switch m {
			case (_,nil,nil):	fatalError("Irrational combination.")
			case (_,nil,_):		snapshot.unionInPlace(m.segment)
			case (_,_,nil):		snapshot.subtractInPlace(m.segment)
			case (_,_,_):		fatalError("Irrational combination.")
			}
			relay.cast(HOTFIX_TimingSignalUtility.didBeginStateByMutation(snapshot, mutation: m))
		}
		relay.cast(HOTFIX_TimingSignalUtility.didBeginStateByTransaction(snapshot, transaction: transaction))
	}

	///	Applies a transaction to an array snapshot and relays the transaction.
	static func apply<T>(transaction: CollectionTransaction<Range<Int>,[T]>, inout to snapshot: [T], relay: Relay<TimingSignal<[T],CollectionTransaction<Range<Int>,[T]>>>) {
		relay.cast(HOTFIX_TimingSignalUtility.willEndStateByTransaction(snapshot, transaction: transaction))
		for m in transaction.mutations {
			relay.cast(HOTFIX_TimingSignalUtility.willEndStateByMutation(snapshot, mutation: m))
			switch m {
			case (_,nil,nil):	fatalError("Irrational combination.")
			case (_,nil,_):		snapshot.splice(m.future!, atIndex: m.segment.startIndex)
			case (_,_,nil):		snapshot.removeRange(m.segment)
			case (_,_,_):		snapshot.replaceRange(m.segment, with: m.future!)
			}
			relay.cast(HOTFIX_TimingSignalUtility.didBeginStateByMutation(snapshot, mutation: m))
		}
		relay.cast(HOTFIX_TimingSignalUtility.didBeginStateByTransaction(snapshot, transaction: transaction))
	}

//	///	Applies a transaction to an array snapshot and relays the transaction.
//	///	This is singl element segment version.
//	static func apply<T>(transaction: CollectionTransaction<Int,T>, inout to snapshot: [T], relay: Relay<TimingSignal<[T],CollectionTransaction<Int,T>>>) {
//		relay.cast(HOTFIX_TimingSignalUtility.willEndStateByTransaction(snapshot, transaction: transaction))
//		for m in transaction.mutations {
//			relay.cast(HOTFIX_TimingSignalUtility.willEndStateByMutation(snapshot, mutation: m))
//			switch m {
//			case (_,nil,nil):	fatalError("Irrational combination.")
//			case (_,nil,_):		snapshot.insert(m.future!, atIndex: m.segment)
//			case (_,_,nil):		snapshot.removeAtIndex(m.segment)
//			case (_,_,_):		snapshot[m.segment]	=	m.future!
//			}
//			relay.cast(HOTFIX_TimingSignalUtility.didBeginStateByMutation(snapshot, mutation: m))
//		}
//		relay.cast(HOTFIX_TimingSignalUtility.didBeginStateByTransaction(snapshot, transaction: transaction))
//	}


	///	Applies a transaction to a dictionary snapshot and relays the transaction.
	static func apply<K: Hashable,V>(transaction: CollectionTransaction<K,V>, inout to snapshot: [K:V], relay: Relay<TimingSignal<[K:V],CollectionTransaction<K,V>>>) {
		relay.cast(HOTFIX_TimingSignalUtility.willEndStateByTransaction(snapshot, transaction: transaction))
		for m in transaction.mutations {
			relay.cast(HOTFIX_TimingSignalUtility.willEndStateByMutation(snapshot, mutation: m))
			switch m {
			case (_,nil,nil):	fatalError("Irrational combination.")
			case (_,nil,_):		snapshot[m.segment]	=	m.future!
			case (_,_,nil):		snapshot[m.segment]	=	nil
			case (_,_,_):		fatalError("Irrational combination.")
			}
			relay.cast(HOTFIX_TimingSignalUtility.didBeginStateByMutation(snapshot, mutation: m))
		}
		relay.cast(HOTFIX_TimingSignalUtility.didBeginStateByTransaction(snapshot, transaction: transaction))
	}

}





