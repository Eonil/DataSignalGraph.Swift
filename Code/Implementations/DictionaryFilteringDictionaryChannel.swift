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
	typealias	IncomingSignal		=	TimingSignal<[K:V],CollectionTransaction<K,V>>
	typealias	OutgoingSignal		=	TimingSignal<[K:V],CollectionTransaction<K,V>>

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
		switch signal {
		case .DidBegin(let subsignal):
			switch subsignal() {
			case .Session(let s):
				_startSessionWithSnapshot(s())
			case .Transaction(let t):
				_applyTransactionWithFiltering(t())
			case .Mutation(let m):
				break
			}
		case .WillEnd(let subsignal):
			switch subsignal() {
			case .Session(let s):
				_finishSessionWithSnapshot(s())
			case .Transaction(let t):
				break
			case .Mutation(let m):
				break
			}
		}
	}

	public func register(identifier: ObjectIdentifier, handler: OutgoingSignal -> ()) {
		if _isOnline() {
			_dispatchSessionBeginSignalToObservers()
		}
		_relay.register(identifier, handler: handler)
	}
	public func deregister(identifier: ObjectIdentifier) {
		_relay.deregister(identifier)
		if _isOnline() {
			_dispatchSessionEndSignalToObservers()
		}
	}
	public func register<S : SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		if _isOnline() {
			_dispatchSessionBeginSignalToObservers()
		}
		_relay.register(s)
	}
	public func deregister<S : SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		_relay.deregister(s)
		if _isOnline() {
			_dispatchSessionEndSignalToObservers()
		}
	}

	///

	private let	_relay		=	Relay<OutgoingSignal>()
	private var	_snapshot	:	[K:V]?

	private func _isOnline() -> Bool {
		return	_snapshot != nil
	}
	private func _startSessionWithSnapshot(snapshot: [K:V]) {
		assert(_isOnline())
		_snapshot	=	snapshot
		_dispatchSessionBeginSignalToObservers()
	}
	private func _finishSessionWithSnapshot(snapshot: [K:V]) {
		assert(_isOnline())
		_dispatchSessionEndSignalToObservers()
		_snapshot	=	nil
	}

	private func _dispatchSessionBeginSignalToObservers() {
		assert(_isOnline())
		_relay.cast(HOTFIX_TimingSignalUtility.didBeginStateBySession(_snapshot!))
	}
	private func _dispatchSessionEndSignalToObservers() {
		assert(_isOnline())
		_relay.cast(HOTFIX_TimingSignalUtility.willEndStateBySession(_snapshot!))
	}

	private func _applyTransactionWithFiltering(transaction: Transaction) {
		let	muts	=	transaction.mutations.map(_filterMutation).filter({ $0 != nil }).map({ $0! })
		let	tran1	=	Transaction(muts)
//		_relay.cast(HOTFIX_TimingSignalUtility.willEndStateByTransaction(_snapshot!, transaction: tran1))
		StateStorageUtility.apply(tran1, to: &_snapshot!, relay: _relay)
//		_relay.cast(HOTFIX_TimingSignalUtility.didBeginStateByTransaction(_snapshot!, transaction: tran1))
	}
	private func _filterMutation(m: Transaction.Mutation) -> Transaction.Mutation? {
		switch (m.past, m.future) {
		case (nil,nil):		fatalError("Unsupported combination.")
		case (nil,_):

			if filter!(m.segment, m.future!) {
				return	m
			}
			return	nil

		case (_,nil):
			if filter!(m.segment, m.past!) {
				return	m
			}
			return	nil

		case (_,_):
			let	pastOK		=	filter!(m.segment, m.past!)
			let	futureOK	=	filter!(m.segment, m.future!)
			switch (pastOK, futureOK) {
			case (false, false):		return	nil
			case (false, true):		return	(m.segment, nil, m.future!)
			case (true, false):		return	(m.segment, m.past!, nil)
			case (true, true):		return	m
			default:			fatalError("Unrecognizable past/future state.")
			}
		}
	}
}



