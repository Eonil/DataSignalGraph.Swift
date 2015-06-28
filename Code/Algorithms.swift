//
//  Algorithms.swift
//  SG4
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

struct Algorithms {
	static func apply<T: Hashable>(transaction: CollectionTransaction<T,()>, inout to snapshot: Set<T>) {
		for m in transaction.mutations {
			switch (m.past, m.future) {
			case (nil, nil):
				fatalError("Illegal signal mutation combination.")
			case (nil, _):
				snapshot.insert(m.identity)
			case (_, nil):
				snapshot.remove(m.identity)
			case (_, _):
				fatalError("Illegal signal mutation combination for set transaction.")
			}
		}
	}
	static func apply<T>(transaction: CollectionTransaction<Int,T>, inout to snapshot: Array<T>) {
		for m in transaction.mutations {
			switch (m.past, m.future) {
			case (nil, nil):
				fatalError("Illegal signal mutation combination.")
			case (nil, _):
				assert(m.identity <= snapshot.count)
				snapshot.insert(m.future!, atIndex: m.identity)
			case (_, nil):
				assert(m.identity < snapshot.count)
				snapshot.removeAtIndex(m.identity)
			case (_, _):
				assert(m.identity < snapshot.count)
				snapshot[m.identity]	=	m.future!
			}
		}
	}
	static func apply<K: Hashable, V>(transaction: CollectionTransaction<K,V>, inout to snapshot: Dictionary<K,V>) {
		for m in transaction.mutations {
			switch (m.past, m.future) {
			case (nil, nil):
				fatalError("Illegal signal mutation combination.")
			case (nil, _):
				snapshot[m.identity]	=	m.future!
			case (_, nil):
				assert(snapshot[m.identity] != nil)
				snapshot.removeValueForKey(m.identity)
			case (_, _):
				assert(snapshot[m.identity] != nil)
				snapshot[m.identity]	=	m.future!
			}
		}
	}

	static func apply<K: Hashable, V>(transaction: CollectionTransaction<K,V>, filter: (K,V)->Bool, inout to snapshot: Dictionary<K,V>) {
		typealias	Mutation	=	CollectionTransaction<K,V>.Mutation
		func _filterMutation(m: Mutation) -> Mutation? {
			switch (m.past, m.future) {
			case (nil,nil):		fatalError("Unsupported combination.")
			case (nil,_):
				if filter(m.identity, m.future!) {
					return	m
				}
				return	nil

			case (_,nil):
				if filter(m.identity, m.past!) {
					return	m
				}
				return	nil

			case (_,_):
				let	pastOK		=	filter(m.identity, m.past!)
				let	futureOK	=	filter(m.identity, m.future!)
				switch (pastOK, futureOK) {
				case (false, false):		return	nil
				case (false, true):		return	(m.identity, nil, m.future!)
				case (true, false):		return	(m.identity, m.past!, nil)
				case (true, true):		return	m
				default:			fatalError("Unrecognizable past/future state.")
				}
			}
		}

		let	muts	=	transaction.mutations.map(_filterMutation).filter({ $0 != nil }).map({ $0! })
		let	tran1	=	CollectionTransaction(muts)
		apply(tran1, to: &snapshot)
	}
}
