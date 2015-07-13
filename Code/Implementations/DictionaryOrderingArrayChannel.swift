//
//  DictionaryOrderingArrayChannel.swift
//  SG4
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class DictionaryOrderingArrayChannel<K: Hashable, V, C: Comparable>: DictionaryOrderingArrayChannelType {
	typealias	Key			=	K
	typealias	Value			=	V
	typealias	Order			=	C
	typealias	Element			=	(K,V)
	typealias	Transaction		=	CollectionTransaction<Int,(K,V)>
	typealias	IncomingSignal		=	StateSignal<[K:V],CollectionTransaction<K,V>>
	typealias	OutgoingSignal		=	StateSignal<[(K,V)],CollectionTransaction<Range<Int>,[(K,V)]>>

	///

	public init() {
	}

	///
	
	public var snapshot: [(K,V)] {
		get {
			return	_snapshot!
		}
	}
	public var order: ((K,V)->C)? {
		willSet {
			assert(_isOnline() == false, "You cannot replace `filter` while this channel is connected to a source storage.")
		}
	}

	public func cast(signal: IncomingSignal) {
		switch signal {
		case .DidBegin(let state, let by):
			switch by() {
			case .Session(let s):
				_connect(s())
			case .Transaction(let t):
				_applyTransactionWithSorting(t())
			case .Mutation(let m):
				break
			}
		case .WillEnd(let state, let by):
			switch by() {
			case .Session(let s):
				_disconnect(state())
			case .Transaction(let t):
				break
			case .Mutation(let m):
				break
			}
		}
	}

	public func register(identifier: ObjectIdentifier, handler: OutgoingSignal -> ()) {
		_relay.register(identifier, handler: handler)
	}
	public func deregister(identifier: ObjectIdentifier) {
		_relay.deregister(identifier)
	}
	public func register<S : SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		_relay.register(s)
	}
	public func deregister<S : SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
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
		_relay.cast(HOTFIX_StateSignalUtility.didBeginStateBySession(_snapshot!))
	}
	private func _disconnect(snapshot: [K:V]) {
		_relay.cast(HOTFIX_StateSignalUtility.willEndStateBySession(_snapshot!))
		_snapshot	=	nil
	}

	private func _applyTransactionWithSorting(transaction: IncomingSignal.Transaction) {
		let	muts	=	_flatten(transaction.mutations.map(_sortMutation))
		let	tran1	=	OutgoingSignal.Transaction(muts)
//		_relay.cast(HOTFIX_StateSignalUtility.willEndStateByTransaction(_snapshot!, transaction: tran1))
		StateStorageUtility.apply(tran1, to: &_snapshot!, relay: _relay)
//		_relay.cast(HOTFIX_StateSignalUtility.didBeginStateByTransaction(_snapshot!, transaction: tran1))
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
			let	idx	=	_findIndexForPair((m.segment, m.future!))
			return	[(idx...idx, nil, [(m.segment, m.future!)])]

		case (_,nil):
			let	idx	=	_findIndexForPair((m.segment, m.past!))
			assert(order!(_snapshot![idx].0, _snapshot![idx].1) == order!(m.segment, m.past!), "A critical bug in algorithm.")
			return	[(idx...idx, [(m.segment, m.past!)], nil)]

		case (_,_):
			return	_sortMutation((m.segment, m.past!, nil)) + _sortMutation((m.segment, nil, m.future!))
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


