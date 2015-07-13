//
//  ArrayMappingArrayChannel.swift
//  SG4
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class ArrayMappingArrayChannel<T,U>: ArrayMappingArrayChannelType {
	typealias	Element			=	U
	typealias	IncomingElement		=	T
	typealias	OutgoingElement		=	U
	typealias	Transaction		=	CollectionTransaction<Range<Int>,[U]>
	typealias	IncomingSignal		=	StateSignal<[T],CollectionTransaction<Range<Int>,[T]>>
	typealias	OutgoingSignal		=	StateSignal<[U],CollectionTransaction<Range<Int>,[U]>>

	///

	public init() {
	}

	///

	public var snapshot: [U] {
		get {
			return	_snapshot!
		}
	}
	public var map: (T->U)? {
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
				_applyTransactionWithMapping(t())

			case .Mutation(let m):
				//	No need to handle this. Ignore it.
				break
			}
		case .WillEnd(let state, let by):
			switch by() {
			case .Session(let s):
				_disconnect(s())

			case .Transaction(let t):
				break

			case .Mutation(let m):
				//	No need to handle this. Ignore it.
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
	private var	_snapshot	:	[U]?

	private func _isOnline() -> Bool {
		return	_snapshot != nil
	}
	private func _connect(snapshot: [T]) {
		_snapshot	=	snapshot.map(map!)
		_relay.cast(HOTFIX_StateSignalUtility.didBeginStateBySession(_snapshot!))
	}
	private func _disconnect(snapshot: [T]) {
		_relay.cast(HOTFIX_StateSignalUtility.willEndStateBySession(_snapshot!))
		_snapshot	=	nil
	}

	private func _applyTransactionWithMapping(transaction: IncomingSignal.Transaction) {
		let	muts	=	transaction.mutations.map(_mapMutation)
		let	tran1	=	OutgoingSignal.Transaction(muts)
//		_relay.cast(HOTFIX_StateSignalUtility.willEndStateByTransaction(_snapshot!, transaction: tran1))
		StateStorageUtility.apply(tran1, to: &_snapshot!, relay: _relay)
//		_relay.cast(HOTFIX_StateSignalUtility.didBeginStateByTransaction(_snapshot!, transaction: tran1))
	}
	private func _mapMutation(m: IncomingSignal.Transaction.Mutation) -> OutgoingSignal.Transaction.Mutation {
		switch (m.past, m.future) {
		case (nil,nil):		fatalError("Unsupported combination.")
		case (nil,_):		return	(m.segment, nil, m.future!.map(map!))
		case (_,nil):		return	(m.segment, m.past!.map(map!), nil)
		case (_,_):		return	(m.segment, m.past!.map(map!), m.future!.map(map!))
		}
	}
}















private func _flatten<T>(c: [[T]]) -> [T] {
	var	a	=	[T]()
	for e in c {
		a.extend(e)
	}
	return	a
}


