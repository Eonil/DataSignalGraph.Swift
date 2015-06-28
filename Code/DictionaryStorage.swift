//
//  DictionaryStorage.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/26.
//  Copyright (c) 2015 Eonil. All rights reserved.
//



public class DictionaryStorage<K: Hashable, V>: CollectionTransactionApplicable {
	public typealias	Signal		=	CollectionSignal<Dictionary<K,V>,K,V>
	
	///
	
	public init(_ snapshot: [K:V]) {
		_snapshot	=	snapshot
		_sigch.owner	=	self
	}
	public var snapshot: Dictionary<K,V> {
		get {
			return	_snapshot
		}
		set(v) {
			_castWillEnd(by: _endSnapshotTransaction())
			_snapshot	=	v
			_castDidBegin(by: _beginSnapshotTransaction())
		}
	}
	public var channel: DictionaryChannel<K,V> {
		get {
			return	_sigch
		}
	}
	
	public func apply(transaction: Signal.Transaction) {
		_castWillEnd(by: transaction)
		_snapshot.apply(transaction)		//	Must apply through `_snapshot` directly to avoid duplicated signal dispatch.
		_castDidBegin(by: transaction)
	}
	
	///
	
	private let	_sigch		=	DictionaryChannel<K,V>()
	private var	_snapshot	=	Dictionary<K,V>()
	
	private func _castDidBegin(by transaction: Signal.Transaction?) {
		_sigch.cast(Signal.DidBegin(state: { [weak self] in self!.snapshot}, by: transaction))
	}
	private func _castWillEnd(by transaction: Signal.Transaction?) {
		_sigch.cast(Signal.WillEnd(state: { [weak self] in self!.snapshot}, by: transaction))
	}
	
	private func _beginSnapshotTransaction() -> Signal.Transaction {
		let	muts	=	map(snapshot, { Signal.Transaction.Mutation($0, nil, $1) })
		return	Signal.Transaction(mutations: muts)
	}
	private func _endSnapshotTransaction() -> Signal.Transaction {
		let	muts	=	map(snapshot, { Signal.Transaction.Mutation($0, $1, nil) })
		return	Signal.Transaction(mutations: muts)
	}
}
//	We can generalize this into single `CollectionChannel` with Swift 2.x features.
public class DictionaryChannel<K: Hashable, V>: SignalChannel<CollectionSignal<[K:V],K,V>> {
	public override func register(identifier: ObjectIdentifier, handler: Signal -> ()) {
		super.register(identifier, handler: handler)
		owner!._castDidBegin(by: nil)
	}
	public override func deregister(identifier: ObjectIdentifier) {
		owner!._castWillEnd(by: nil)
		super.deregister(identifier)
	}

	///

	private weak var owner: DictionaryStorage<K,V>?
}



extension DictionaryStorage {
	public var count: Int {
		get {
			return	_snapshot.count
		}
	}
	public subscript(key: K) -> V? {
		get {
			return	_snapshot[key]
		}
		set(v) {
			let	maybeOld	=	_snapshot[key]
			let	maybeNew	=	v
			
			switch (maybeOld, maybeNew) {
			case (nil, nil):
				break
				
			case (nil, _):
				apply(CollectionTransaction(mutations: [(key, nil, maybeNew)]))
				
			case (_, nil):
				apply(CollectionTransaction(mutations: [(key, maybeOld, nil)]))
				
			case (_, _):
				apply(CollectionTransaction(mutations: [(key, maybeOld, maybeNew)]))
			}
		}
	}
	
	///
	
	public func updateValue(value: V, forKey key: K) -> V? {
		let	maybeOld	=	_snapshot[key]
		let	new		=	value
		switch (maybeOld, new) {
		case (nil,_):		apply(CollectionTransaction(mutations: [(key, nil, new)]))
		case (_,_):		apply(CollectionTransaction(mutations: [(key, maybeOld!, new)]))
		}
		return	maybeOld
	}
	
	public func removeAtIndex(index: DictionaryIndex<K, V>) {
		let	pair	=	_snapshot[index]
		let	key	=	pair.0
		let	old	=	pair.1
		apply(CollectionTransaction(mutations: [(key, old, nil)]))
	}
	
	public func removeValueForKey(key: K) -> V? {
		let	maybeOld	=	_snapshot[key]
		if let old = maybeOld {
			apply(CollectionTransaction(mutations: [(key, old, nil)]))
		}
		return	maybeOld
	}
	
	public func removeAll() {
		var	muts		=	Array<Signal.Transaction.Mutation>()
		for (k,v) in _snapshot {
			muts.append((k, v, nil))
		}
		apply(CollectionTransaction(mutations: muts))
	}
	
	public var keys: LazyForwardCollection<MapCollectionView<[K:V],K>> {
		get {
			return	_snapshot.keys
		}
	}
	public var values: LazyForwardCollection<MapCollectionView<[K:V],V>> {
		get {
			return	_snapshot.values
		}
	}
}







