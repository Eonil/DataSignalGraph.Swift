//
//  Diff.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/06/30.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

///	A `Diff` describes mutations on a snapshot state.
///
///	Array diff must be applicated from back to forth by its index order.
///	Then, for the best performance, it must be sorted in descending index order.
///	Anyway even in this case, array diff cannot provide post-diff indexes. The 
///	indexes can be resolved only by emulating actual mutations.
///
///	You cannot make this value with duplicated keys.
///	If you're not sure whether keys are duplicated or not,
///	please use `checkDuplication` to check it.
///
public struct Diff<K: Hashable, V> {
	public typealias	Mutation	=	CollectionTransaction<K,V>.Mutation

	public let	inserts		:	[Mutation]
	public let	updates		:	[Mutation]
	public let	deletes		:	[Mutation]

	public init(inserts: [Mutation], updates: [Mutation], deletes: [Mutation]) {
		assert(_hasAnyDuplication((inserts, updates, deletes)) == false, "This value should not contain any duplicated keys.")
		self.inserts	=	inserts
		self.updates	=	updates
		self.deletes	=	deletes
	}

	///

	internal typealias	Tuple	=	(inserts: [Mutation], updates: [Mutation], deletes: [Mutation])
}
private func _hasAnyDuplication<K: Hashable, V>(diff: Diff<K,V>.Tuple) -> Bool {
	let	pairCount	=	diff.inserts.count + diff.updates.count + diff.deletes.count
	let	keyCount	=	_countKeys(diff)
	return	keyCount != pairCount
}
private func _countKeys<K: Hashable, V>(tuple: Diff<K,V>.Tuple) -> Int {
	var	keyset		=	Set<K>()
	tuple.inserts.map({keyset.insert($0.identity)})
	tuple.updates.map({keyset.insert($0.identity)})
	tuple.deletes.map({keyset.insert($0.identity)})
	return	keyset.count
}



public extension Diff {
	public static func resolve(transaction: DictionaryStorage<K,V>.Signal.Transaction) -> Diff<K,V> {
		return	resolve(transaction.mutations)
	}
	public static func resolve(mutations: [DictionaryStorage<K,V>.Signal.Transaction.Mutation]) -> Diff<K,V> {
		var	dop	=	_DictionaryMutationDeduplicator<K,V>()
		for m in mutations {
			switch m {
			case (_,nil,nil):	fatalError()
			case (_,nil,_):		dop.pushInsert(m.identity, v: (m.past, m.future))
			case (_,_,nil):		dop.pushDelete(m.identity, v: (m.past, m.future))
			case (_,_,_):		dop.pushUpdate(m.identity, v: (m.past, m.future))
			}
		}
		return	dop.diff()
	}

}

///	Requires removing to be performed first.
private struct _DictionaryMutationDeduplicator<K: Hashable, V> {
	var	inserts		=	[K:(V?,V?)]()
	var	updates		=	[K:(V?,V?)]()
	var	deletes		=	[K:(V?,V?)]()
	///	Anyway pushing can be made in any order.
	mutating func pushInsert(k: K, v: (V?,V?)) {
		assert(inserts[k] == nil)
		assert(updates[k] == nil)
		if deletes[k] != nil {
			deletes.removeValueForKey(k)
			return
		}
		inserts[k]	=	v
	}
	mutating func pushUpdate(k: K, v: (V?,V?)) {
		assert(inserts[k] == nil)
		assert(deletes[k] == nil)
		if inserts[k] != nil {
			inserts.removeValueForKey(k)
			return
		}
		updates[k]	=	v
	}
	mutating func pushDelete(k: K, v: (V?,V?)) {
		assert(deletes[k] == nil)
		if inserts[k] != nil {
			inserts.removeValueForKey(k)
			return
		}
		if updates[k] != nil {
			updates.removeValueForKey(k)
			return
		}
		deletes[k]	=	v
	}
	func diff() -> Diff<K,V> {
		func buildMutationList(dict: [K:(V?,V?)]) -> Array<Diff<K,V>.Mutation> {
			var	ms	=	Array<Diff<K,V>.Mutation>()
			for (k,vv) in dict {
				ms.append((k, vv.0, vv.1))
			}
			return	ms
		}
		return	Diff(
			inserts	:	buildMutationList(inserts),
			updates	:	buildMutationList(updates),
			deletes	:	buildMutationList(deletes))
	}
}

























