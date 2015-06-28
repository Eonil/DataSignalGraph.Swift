//
//  DictionaryFilteringDictionaryStorage.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/06/27.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

///	Signaling session will be deferred until signaling session of storage to be started.
///
///
///	Internals
///	---------
///	Keeping a filtered dictionary (local cache) is required to keep snapshot cost O(1).
///
public final class DictionaryFilteringDictionaryStorage<K: Hashable, V>: ChannelType {
	public typealias	Signal		=	CollectionSignal<Dictionary<K,V>,K,V>
	public typealias	Filter		=	(K,V)->Bool

	public init() {
	}
	public convenience init(_ filter: K->Bool) {
		self.init()
		self.filter	=	{ filter($0.0) }
	}
	public convenience init(_ filter: Filter) {
		self.init()
		self.filter	=	filter
	}
	deinit {
	}

	///

	public func cast(signal: Signal) {
		_processSignal(signal)
	}
	public func register(identifier: ObjectIdentifier, handler: Signal -> ()) {
		_processRegistration(identifier, handler: handler)
	}
	public func deregister(identifier: ObjectIdentifier) {
		_processDeregistration(identifier)
	}



	///	:param:		filter
	///			Defines allowed key-value pairs.
	///
	///			REQUIREMENTS
	///			------------
	///			This function must be **referentially transparent**.
	///			That means same input must produce same output always.
	///			In other words, do not change internal logic while this
	///			function is bound to this object.
	///
	///			This function should be very cheap because this function will be
	///			called very frequently, and evaluation result will not be memoized
	///			at all. (you can do it yourself if you want)
	///

	public var filter: Filter? {
		willSet {
			assert(_isOnline() == false, "You cannot replace filter while this storage is on-line.")
		}
		didSet {
		}
	}

	///

	///	Keeps all registered handlers here and register to `_filteredDS` when
	///	it becomes ready.
	private var	_handlerPairs	=	Dictionary<ObjectIdentifier,Signal->()>()

	///	Create and destory on-demand.
	private var	_filteredDS	:	DictionaryStorage<K,V>?

	private func _processSignal(signal: Signal){
		switch signal {
		case .DidBegin(let state, let by):
			switch by {
			case nil:
				_switchToOnline(state())
			case _:
				_applyTransactionWithFiltering(by!)
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
		_filteredDS	=	DictionaryStorage(snapshot)
		for pair in _handlerPairs {
			_filteredDS!.channel.register(pair.0, handler: pair.1)
		}
	}
	private func _switchToOffline(snapshot: [K:V]) {
		for pair in _handlerPairs {
			_filteredDS!.channel.deregister(pair.0)
		}
		_filteredDS	=	nil
	}
	private func _isOnline() -> Bool {
		return	_filteredDS != nil
	}

	private func _processRegistration(identifier: ObjectIdentifier, handler: Signal->()) {
		if _isOnline() {
			_filteredDS!.channel.register(identifier, handler: handler)
		} else {
			assert(_handlerPairs[identifier] == nil)
			_handlerPairs[identifier]	=	handler
		}
	}
	private func _processDeregistration(identifier: ObjectIdentifier) {
		if _isOnline() {
			_filteredDS!.channel.deregister(identifier)
		} else {
			assert(_handlerPairs[identifier] != nil)
			_handlerPairs[identifier]	=	nil
		}
	}
	private func _applyTransactionWithFiltering(transaction: Signal.Transaction) {
		let	muts	=	transaction.mutations.map(_filterMutation).filter({ $0 != nil }).map({ $0! })
		let	tran1	=	Signal.Transaction(mutations: muts)
		_filteredDS!.apply(tran1)
	}
	private func _filterMutation(m: Signal.Transaction.Mutation) -> Signal.Transaction.Mutation? {
		switch (m.past, m.future) {
		case (nil,nil):		fatalError("Unsupported combination.")
		case (nil,_):
			if filter!(m.identity, m.future!) {
				return	m
			}
			return	nil

		case (_,nil):
			if filter!(m.identity, m.past!) {
				return	m
			}
			return	nil

		case (_,_):
			let	pastOK		=	filter!(m.identity, m.past!)
			let	futureOK	=	filter!(m.identity, m.future!)
			switch (pastOK, futureOK) {
			case (false, false):		return	nil
			case (false, true):		return	(m.identity, nil, m.future!)
			case (true, false):		return	(m.identity, m.past!, nil)
			case (true, true):		return	m
			default:			fatalError("Unrecognizable past/future state.")
			}
		}
	}
}




extension DictionaryFilteringDictionaryStorage {
	public var snapshot: [K:V] {
		get {
			return	_filteredDS!.snapshot
		}
	}
}




































