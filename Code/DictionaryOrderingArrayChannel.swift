//
//  DictionaryOrderingArrayChannel.swift
//  SG4
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

class DictionaryOrderingArrayChannel<K: Hashable, V, C: Comparable>: DictionaryOrderingArrayChannelType {
	typealias	Key			=	K
	typealias	Value			=	V
	typealias	Order			=	C
	typealias	Element			=	(K,V)
	typealias	Transaction		=	CollectionTransaction<Int,(K,V)>
	typealias	IncomingSignal		=	StateSignal<[K:V],CollectionTransaction<K,V>>
	typealias	OutgoingSignal		=	StateSignal<[(K,V)],CollectionTransaction<Int,(K,V)>>

	///

	var snapshot: [(K,V)] {
		get {
			return	_snapshot!
		}
	}
	var order: ((K,V)->C)? {
		willSet {
			assert(_isOnline() == false, "You cannot replace `filter` while this channel is connected to a source storage.")
		}
	}

	func cast(signal: IncomingSignal) {
		switch signal.timing {
		case .DidBegin:
			if signal.by == nil {
				_connect(signal.state)
			}
			if let by = signal.by {
				_applyTransactionWithSorting(by)
			}

		case .WillEnd:
			if signal.by == nil {
				_disconnect(signal.state)
			}
		}
	}

	func register(identifier: ObjectIdentifier, handler: OutgoingSignal -> ()) {
		_relay.register(identifier, handler: handler)
	}
	func deregister(identifier: ObjectIdentifier) {
		_relay.deregister(identifier)
	}
	func register<S : SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		_relay.register(s)
	}
	func deregister<S : SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		_relay.deregister(s)
	}

	///

	private let	_relay		=	Relay<OutgoingSignal>()
	private var	_snapshot	:	[(K,V)]?

	private func _isOnline() -> Bool {
		return	_snapshot != nil
	}
	private func _connect(snapshot: [K:V]) {
		_snapshot	=	_sortSnapshot(snapshot)
		_relay.cast(OutgoingSignal.didBegin(_snapshot!, by: nil))
	}
	private func _disconnect(snapshot: [K:V]) {
		_relay.cast(OutgoingSignal.willEnd(_snapshot!, by: nil))
		_snapshot	=	nil
	}

	private func _applyTransactionWithSorting(transaction: IncomingSignal.Transaction) {
		let	muts	=	_flatten(transaction.mutations.map(_sortMutation))
		let	tran1	=	OutgoingSignal.Transaction(muts)
		_relay.cast(StateSignal.willEnd(_snapshot!, by: tran1))
		Algorithms.apply(tran1, to: &_snapshot!)
		_relay.cast(StateSignal.didBegin(_snapshot!, by: tran1))
	}

	private func _sortSnapshot(snapshot: [K:V]) -> Array<(K,V)> {
		func usingOrder(a: (K,V), b: (K,V)) -> Bool {
			let	ord1	=	self.order!(a)
			let	ord2	=	self.order!(b)
			return	ord1 < ord2
		}
		return	map(snapshot, {($0.0,$0.1)}).sorted(usingOrder)
	}
	private func _sortMutation(m: IncomingSignal.Transaction.Mutation) -> [OutgoingSignal.Transaction.Mutation] {
		switch (m.past, m.future) {
		case (nil,nil):		fatalError("Unsupported combination.")
		case (nil,_):
			let	idx	=	_findIndexForPair((m.identity, m.future!))
			return	[(idx, nil, (m.identity, m.future!))]

		case (_,nil):
			let	idx	=	_findIndexForPair((m.identity, m.past!))
			assert(order!(_snapshot![idx].0, _snapshot![idx].1) == order!(m.identity, m.past!), "A critical bug in algorithm.")
			return	[(idx, (m.identity, m.past!), nil)]

		case (_,_):
			return	_sortMutation((m.identity, m.past!, nil)) + _sortMutation((m.identity, nil, m.future!))
		}
	}

	private func _findIndexForPair(pair: (K,V)) -> Int {
		return	_findIndexOfOrder(order!(pair))
	}
	private func _findIndexOfOrder(order: C) -> Int {
		//	TODO:	`_sortedAS` is literally sorted. Use binary search.

		for i in 0..<_snapshot!.count {
			let	pair	=	_snapshot![i]
			let	order1	=	self.order!(pair)
			let	order2	=	order
			if order1 >= order2 {
				return	i
			}
		}
		return	_snapshot!.count
	}
}















private func _flatten<T>(c: [[T]]) -> [T] {
	var	a	=	[T]()
	for e in c {
		a.extend(e)
	}
	return	a
}


