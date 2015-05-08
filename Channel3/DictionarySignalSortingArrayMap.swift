//
//  DictionarySignalSortingArrayMap.swift
//  Channel3
//
//  Created by Hoon H. on 2015/05/08.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

///	Manages a sorted array by sorting a virtual dictionary coming from dictionary signal
///	in ascending order.
///	
///	The mutation operation needs binary search lookup that costs `O(log N)`.
///	First/last orders are checked first, so if you're inserting/updating/deleting entries
///	at first/last order, lookup cost will be `O(1)`.
///	Anyway this is only lookup cost. Mutation operation itself on the `Array` will just 
///	follow mutation cost of the `Array` type. See the type documentation for details.
///
public class DictionarySignalSortingArrayMap<K,V,C where K: Hashable, C: Comparable> {
	
	///	:param:		order
	///				Creates a comparable object to be used for sorting the entries.
	///				This function will be called very frequently, so should be very cheap.
	///
	public init(_ order: (K,V)->C) {
		self.order				=	order
		self.monitor			=	SignalMonitor()
		self.monitor.handler	=	{ [weak self] s in self!.process(s) }
	}
	
	///	A sensor to receive dictionary signal.
	public var sensor: SignalSensor<DictionarySignal<K,V>> {
		get {
			return	monitor
		}
	}
	
	///	A reconstructed array from the dictionary signal
	///	using the ordering.
	public var array: ArrayStorage<(K,V)> {
		get {
			return	replication
		}
	}
	
	////
	
	private typealias	M	=	CollectionTransaction<Int,(K,V)>.Mutation
	
	private let	replication	=	ArrayReplication<(K,V)>()
	private let	monitor		:	SignalMonitor<DictionarySignal<K,V>>
	private let	order		:	(K,V) -> C
	
	private var editor: ArrayEditor<(K,V)> {
		get {
			return	ArrayEditor(replication)
		}
	}
	
	private func process(s: DictionarySignal<K,V>) {
		switch s {
		case .Initiation(let s):
			for e in s {
				insert(e)
			}
		case .Transition(let s):
			for m in s.mutations {
				switch (m.past == nil, m.future == nil) {
				case (true, false):		insert(m.identity, m.future!)
				case (false, false):	update(m.identity, m.future!)
				case (false, true):		delete(m.identity, m.future!)
				default:				fatalError("Unsupported mutation pattern. This shouldn't be exist.")
				}
			}
		case .Termination(let s):
			replication.sensor.signal(ArraySignal.Termination(snapshot: replication.state))
//			for e in s {
//				delete(e)
//			}
		}
	}
	
	///	Order between entries must be fully resolved.
	///	Ambiguous order will produce unstable resulting array.
	private func insert(e: (K,V)) {
		let	i	=	findIndexForOrder(order(e))
		var	ed	=	editor
		precondition(i == ed.count || ed[i].0 != e.0, "There should be no equal existing key.")
		ed.insert(e, atIndex: i)
	}
	private func update(e: (K,V)) {
		let	i	=	findIndexForOrder(order(e))
		var	ed	=	editor
		precondition(ed[i].0 == e.0, "Keys must be matched.")
		ed[i]	=	e
	}
	private func delete(e: (K,V)) {
		let	i	=	findIndexForOrder(order(e))
		var	ed	=	editor
		precondition(ed[i].0 == e.0, "Keys must be matched.")
		ed.removeAtIndex(i)
	}
	
	///	Find an index for specified order.
	///
	///	If there's an existing entry with same order,
	///	this will return index of the entry. 
	///
	///	If there's no existing entry for the order,
	///	this will return smallest index for an entry that
	///	has larger order than the supplied order. This is
	///	proper index to insert a new entry.
	///
	///	This performs binary search. Should be `O(log N)`.
	///
	private func findIndexForOrder(c: C) -> Int {
		if let last = array.state.last {
			if order(last) >= c {
				return	array.state.count
			}
		}
		
		//	TODO:	Re-implement using binary search.
		//			The array must always be sorted in ascending order.
		for i in 0..<array.state.count {
			let	e	=	array.state[i]
			let	o	=	order(e)
			if o >= c {
				return	i
			}
		}
		
		//	Don't forget the case where `array.count == 0`.
		return	array.state.count
	}
}







