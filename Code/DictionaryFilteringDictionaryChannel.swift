//
//  DictionaryFilteringDictionaryChannel.swift
//  SG4
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class DictionaryFilteringDictionaryChannel<K: Hashable, V>: DictionaryFilteringDictionaryChannelType {
	typealias	Key			=	K
	typealias	Value			=	V
	typealias	Transaction		=	CollectionTransaction<K,V>
	typealias	IncomingSignal		=	StateSignal<[K:V],CollectionTransaction<K,V>>
	typealias	OutgoingSignal		=	StateSignal<[K:V],CollectionTransaction<K,V>>

	///

	public init() {
	}

	///

	public var snapshot: [K:V] {
		get {
			return	_snapshot!
		}
	}
	public var filter: ((K,V)->Bool)? {
		willSet {
			assert(_isOnline() == false, "You cannot replace `filter` while this channel is connected to a source storage.")
		}
	}

	public func cast(signal: IncomingSignal) {
		switch signal.timing {
		case .DidBegin:
			if signal.by == nil {
				_connect(signal.state)
			}
			if let by = signal.by {
				_applyTransactionWithFiltering(by)
			}

		case .WillEnd:
			if signal.by == nil {
				_disconnect(signal.state)
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
	private var	_snapshot	:	[K:V]?

	private func _isOnline() -> Bool {
		return	_snapshot != nil
	}
	private func _connect(snapshot: [K:V]) {
		_snapshot	=	snapshot
		_relay.cast(OutgoingSignal.didBegin(_snapshot!, by: nil))
	}
	private func _disconnect(snapshot: [K:V]) {
		_relay.cast(OutgoingSignal.willEnd(_snapshot!, by: nil))
		_snapshot	=	nil
	}

	private func _applyTransactionWithFiltering(transaction: Transaction) {
		let	muts	=	transaction.mutations.map(_filterMutation).filter({ $0 != nil }).map({ $0! })
		let	tran1	=	Transaction(muts)
		_relay.cast(StateSignal.willEnd(_snapshot!, by: tran1))
		Algorithms.apply(tran1, to: &_snapshot!)
		_relay.cast(StateSignal.didBegin(_snapshot!, by: tran1))
	}
	private func _filterMutation(m: Transaction.Mutation) -> Transaction.Mutation? {
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



