//
//  DictionaryStorageEditor.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/05/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//



///	A zero-cost wrapper around a `ReplicatingDictionaryStorage`
///	which provides dictionary-like interface.
///
///	This produces and sends `DictionarySignal` to `origin` to
///	mutate it. Mutator methods also returns appropriate
///	values.
///
public struct DictionaryStorageEditor<K: Hashable,V>: CollectionType {
	
	public static func initiate(storage: ReplicatingDictionaryStorage<K,V>, snapshot: [K:V]) {
		let	s	=	DictionarySignal<K,V>.Initiation(snapshot: snapshot)
		storage.sensor.signal(s)
	}
	public static func terminate(storage: ReplicatingDictionaryStorage<K,V>, snapshot: [K:V]) {
		let	s	=	DictionarySignal<K,V>.Termination(snapshot: snapshot)
		storage.sensor.signal(s)
	}
	
	///
	
	public unowned let	storage	:	ReplicatingDictionaryStorage<K,V>
	
	public init(_ storage: ReplicatingDictionaryStorage<K,V>) {
		self.storage		=	storage
	}
	
	///
	
	public var startIndex: Dictionary<K,V>.Index {
		get {
			return	storage.state.startIndex
		}
	}
	public var endIndex: Dictionary<K,V>.Index {
		get {
			return	storage.state.endIndex
		}
	}
	public var count: Int {
		get {
			return	storage.state.count
		}
	}
	
	public subscript(index: Dictionary<K,V>.Index) -> (K,V) {
		get {
			return	storage.state[index]
		}
	}
	public subscript(k: K) -> V? {
		get {
			return	storage.state[k]
		}
		set(v) {
			//	TODO:	Find out behavior in case of `v == nil`
			//			and define a proper behavior.
			assert(v != nil, "The value `v` should not be a `nil`. Operation is not defined yet.")
			if let _ = storage.state[k] {
				let	ms	=	[updateMutation(k, v!)]
				dispatchMutations(ms)
			} else {
				let	ms	=	[insertMutation(k, v!)]
				dispatchMutations(ms)
			}
		}
	}
	
	public func generate() -> Dictionary<K,V>.Generator {
		return	storage.state.generate()
	}
	
	public mutating func removeValueForKey(k: K) -> V? {
		let	v	=	storage.state[k]
		let	ms	=	[deleteMutation(k)]
		dispatchMutations(ms)
		return	v
	}
	public mutating func removeAll() {
		storage.sensor.signal(DictionarySignal.Termination(snapshot: storage.state))
		storage.sensor.signal(DictionarySignal.Initiation(snapshot: [:]))
	}
	
	///
	
	private typealias	M	=	CollectionTransaction<K,V>.Mutation
	
	private func insertMutation(k: K, _ v: V) -> M {
		assert(self[k] == nil, "You cannot make an insert mutation for key `\(k)` because there's a value `\(self[k]!)` registered with the key.")
		return	M(k, nil, v)
	}
	private func updateMutation(k: K, _ v: V) -> M {
		assert(self[k] != nil, "You cannot make an update mutation for key `\(k)` because there's no value registered with the key.")
		return	M(k, self[k], v)
	}
	private func deleteMutation(k: K) -> M {
		assert(self[k] != nil, "You cannot make an delete mutation for key `\(k)` because there's no value registered with the key.")
		return	M(k, self[k], nil)
	}
	private func dispatchMutations(ms: [M]) {
		let	t	=	CollectionTransaction(mutations: ms)
		let	s	=	DictionarySignal.Transition(transaction: t)
		storage.sensor.signal(s)
	}
}

