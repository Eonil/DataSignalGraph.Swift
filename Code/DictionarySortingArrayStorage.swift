//
//  DictionarySortingArrayStorage.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/06/27.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class DictionarySortingArrayStorage<K: Hashable, V, C: Comparable>: ChannelType {
	public typealias	Order		=	(K,V)->C

	public init() {
	}
	public convenience init(order: Order) {
		self.init()
		self.order	=	order
	}
	deinit {
	}

	///

	///	:param:		order
	///			Creates a comparable "order" for an entry.
	///			This class will sort entries using the returning order object in ascending
	///			order.
	///
	///			REQUIREMENTS
	///			------------
	///			This function must be **referentially transparent**.
	///			That means same input must produce same output always.
	///			In other words, do not change internal logic while this
	///			function is bound to this object.
	///
	///			This function must be very cheap because this function will be
	///			called very frequently, and evaluation result will not be memoized
	///			at all. (you can do it yourself if you want)
	///
	public var order: Order? {
		willSet {
			assert(_isOnline() == false, "You cannot replace sort while this storage is on-line.")
		}
		didSet {
		}
	}

	public func cast(signal: CollectionSignal<[K:V],K,V>) {
		_processSignal(signal)
	}
	public func register(identifier: ObjectIdentifier, handler: CollectionSignal<[(K,V)],Int,(K,V)> -> ()) {
		_processRegistration(identifier, handler: handler)
	}
	public func deregister(identifier: ObjectIdentifier) {
		_processDeregistration(identifier)
	}

	///

	private typealias	_InputSignal	=	CollectionSignal<[K:V],K,V>
	private typealias	_OutputSignal	=	CollectionSignal<[(K,V)],Int,(K,V)>

	///	Keeps all registered handlers here and register to `_filteredDS` when
	///	it becomes ready.
	private var	_handlerPairs	=	Dictionary<ObjectIdentifier,_OutputSignal->()>()

	///	Create and destory on-demand.
	private var	_sortedAS	:	ArrayStorage<(K,V)>?

	private func _processSignal(signal: _InputSignal){
		switch signal {
		case .DidBegin(let state, let by):
			switch by {
			case nil:
				_switchToOnline(state())
			case _:
				_applyTransactionWithSorting(by!)
			}
		case .WillEnd(let state, let by):
			switch by {
			case nil:
				_switchToOffline(state())
			case _:
				break
			}
		}
	}

	private func _switchToOnline(snapshot: [K:V]) {
		_sortedAS	=	ArrayStorage(_sortSnapshot(snapshot))
		for pair in _handlerPairs {
			_sortedAS!.register(pair.0, handler: pair.1)
		}
	}
	private func _switchToOffline(snapshot: [K:V]) {
		for pair in _handlerPairs {
			_sortedAS!.deregister(pair.0)
		}
		_sortedAS	=	nil
	}
	private func _isOnline() -> Bool {
		return	_sortedAS != nil
	}

	private func _processRegistration(identifier: ObjectIdentifier, handler: _OutputSignal->()) {
		if _isOnline() {
			_sortedAS!.register(identifier, handler: handler)
		} else {
			assert(_handlerPairs[identifier] == nil)
			_handlerPairs[identifier]	=	handler
		}
	}
	private func _processDeregistration(identifier: ObjectIdentifier) {
		if _isOnline() {
			_sortedAS!.deregister(identifier)
		} else {
			assert(_handlerPairs[identifier] != nil)
			_handlerPairs[identifier]	=	nil
		}
	}

	private func _sortSnapshot(snapshot: [K:V]) -> Array<(K,V)> {
		func usingOrder(a: (K,V), b: (K,V)) -> Bool {
			let	ord1	=	self.order!(a)
			let	ord2	=	self.order!(b)
			return	ord1 < ord2
		}
		return	map(snapshot, {($0.0,$0.1)}).sorted(usingOrder)
	}
	private func _applyTransactionWithSorting(transaction: _InputSignal.Transaction) {
		let	muts	=	_flatten(transaction.mutations.map(_sortMutation))
		let	tran1	=	_OutputSignal.Transaction(mutations: muts)
		_sortedAS!.apply(tran1)
	}
	private func _sortMutation(m: _InputSignal.Transaction.Mutation) -> [_OutputSignal.Transaction.Mutation] {
		switch (m.past, m.future) {
		case (nil,nil):		fatalError("Unsupported combination.")
		case (nil,_):
			let	idx	=	_findIndexForPair((m.identity, m.future!))
			return	[(idx, nil, (m.identity, m.future!))]

		case (_,nil):
			let	idx	=	_findIndexForPair((m.identity, m.past!))
			assert(order!(_sortedAS![idx].0, _sortedAS![idx].1) == order!(m.identity, m.past!), "A critical bug in algorithm.")
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

		for i in 0..<_sortedAS!.count {
			let	pair	=	_sortedAS![i]
			let	order1	=	self.order!(pair)
			let	order2	=	order
			if order1 >= order2 {
				return	i
			}
		}
		return	_sortedAS!.count
	}
}

extension DictionarySortingArrayStorage {
	public var snapshot: [(K,V)] {
		get {
			return	_sortedAS!.snapshot
		}
	}
}
//	For Swift 2.0+.
//extension DictionarySortingArrayStorage where K: Comparable {
//	public convenience init(comparison: Comparison) {
//		self.init()
//		self.sort	=	(order: {$0}, comparison: comparison)
//	}
//}











private func _flatten<T>(c: [[T]]) -> [T] {
	var	a	=	[T]()
	for e in c {
		a.extend(e)
	}
	return	a
}










