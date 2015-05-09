//
//  DictionarySignalSortingArrayStorage.swift
//  Channel3
//
//  Created by Hoon H. on 2015/05/08.
//  Copyright (c) 2015 Eonil. All rights reserved.
//



///	Manages a sorted array in ascending order by sorting a virtual dictionary derived from
///	dictionary signal.
///	
///	The mutation operation needs binary search lookup that costs `O(log N)`.
///	First/last orders are checked earlier. If you're inserting/updating/deleting entries
///	at first/last order, lookup cost will be `O(1)`.
///	Anyway this is only lookup cost. Mutation operation itself on the `Array` will just 
///	follow mutation cost of the `Array` type. See the type documentation for details.
///
public class DictionarySignalSortingArrayStorage<K,V,C where K: Hashable, C: Comparable>: StorageType {
	
	///	:param:		order
	///				Creates a comparable order for an entry.
	///				This class will sort entries using the returning object in ascending
	///				order.
	///
	///				REQUIREMENTS
	///				------------
	///				This function must be **referentially transparent**.
	///				That means same input must produce same output always.
	///				In other words, do not change internal logic of this while this 
	///				function is bound to this object.
	///
	///				This function should be very cheap because this function will be
	///				called very frequently, and evaluation result will not be memoized
	///				at all. (so you can do it yourself if desired)
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
	public var state: [(K,V)] {
		get {
			return	replication.state
		}
	}
	public var emitter: SignalEmitter<ArraySignal<(K,V)>> {
		get {
			return	replication.emitter
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
	
	///	Central signal processor.
	///	Signals will be distributd to a proper subprocessing
	///	methods by need.
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
				case (false, false):	update(m.identity, m.past!, m.future!)
				case (false, true):		delete(m.identity, m.past!)
				default:				fatalError("Unsupported mutation pattern. This shouldn't be exist.")
				}
			}
		case .Termination(let s):
			replication.sensor.signal(ArraySignal.Termination(snapshot: replication.state))
			replication.sensor.signal(ArraySignal.Initiation(snapshot: []))
//			for e in s {
//				delete(e)
//			}
		}
	}

	///	Order between entries must be fully clean.
	///	It is your responsibility that ensuring clear ordering.
	///	Ambiguous order will produce unstable resulting array,
	///	so do not use it unless it's your intention.
	private func insert(e: (K,V)) {
		let	i	=	findIndexForOrder(order(e))
		var	ed	=	editor
		precondition(i == ed.count || ed[i].0 != e.0, "There should be no equal existing key.")
		ed.insert(e, atIndex: i)
	}
	///	Sorting index is resolved by pair of key and value, 
	///	and can be changed after value changed.
	private func update(e: (K,V,V)) {
		let	i0	=	findIndexForOrder(order(e.0, e.1))
		var	ed	=	editor
		precondition(ed[i0].0 == e.0, "Keys must be matched.")
		ed.removeAtIndex(i0)
		
		//	Index resolution is execution order dependent.
		//	Resolve it after removing finished.
		let	i1	=	findIndexForOrder(order(e.0, e.2))
		ed.insert((e.0, e.2), atIndex: i1)
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
	///	has equals or larger order than the supplied order. 
	///	This is a proper index to insert a new entry at a 
	///	proper ascending order.
	///
	///	This performs binary search. Should be `O(log N)`.
	///
	private func findIndexForOrder(c: C) -> Int {
		if let last = state.last {
			if order(last) < c {
				println(order(last))
				return	state.count
			}
		}
		
		//	TODO:	Re-implement using binary search.
		//			The array must always be sorted in ascending order.
		for i in 0..<state.count {
			let	e	=	state[i]
			let	o	=	order(e)
			if o >= c {
				return	i
			}
		}
		
		//	Don't forget the case where `array.count == 0` that
		//	will not be handled by above.
		return	state.count
	}
}







