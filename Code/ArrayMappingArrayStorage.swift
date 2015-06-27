//
//  ArrayMappingArrayStorage.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/06/27.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class ArrayMappingArrayStorage<T,U> {
	public typealias	Map	=	T->U

	public init() {
	}
	public convenience init(_ map: Map) {
		self.init()
	}

	///	:param:		map
	///			Defines value conversion.
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
	var map: Map? {
		willSet {
			assert(_isOnline() == false, "You cannot replace filter while this storage is on-line.")
		}
	}

	///

	public func cast(signal: CollectionSignal<[T],Int,T>) {
		assert(map != nil, "You cannot `cast` signals to a storage with no `map`.")
		_processSignal(signal)
	}
	public func register(identifier: ObjectIdentifier, handler: CollectionSignal<[U],Int,U> -> ()) {
		_processRegistration(identifier, handler: handler)
	}
	public func deregister(identifier: ObjectIdentifier) {
		_processDeregistration(identifier)
	}

	///

	private typealias	_InputSignal	=	CollectionSignal<[T],Int,T>
	private typealias	_OutputSignal	=	CollectionSignal<[U],Int,U>

	///	Keeps all registered handlers here and register to `_filteredDS` when
	///	it becomes ready.
	private var	_handlerPairs	=	Dictionary<ObjectIdentifier,_OutputSignal->()>()

	///	Create and destory on-demand.
	private var	_mappedAS	:	ArrayStorage<U>?

	private func _processSignal(signal: _InputSignal){
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

	private func _switchToOnline(snapshot: [T]) {
		_mappedAS	=	ArrayStorage(snapshot.map(map!))
		for pair in _handlerPairs {
			_mappedAS!.register(pair.0, handler: pair.1)
		}
	}
	private func _switchToOffline(snapshot: [T]) {
		for pair in _handlerPairs {
			_mappedAS!.deregister(pair.0)
		}
		_mappedAS	=	nil
	}
	private func _isOnline() -> Bool {
		return	_mappedAS != nil
	}

	private func _processRegistration(identifier: ObjectIdentifier, handler: _OutputSignal->()) {
		if _isOnline() {
			_mappedAS!.register(identifier, handler: handler)
		} else {
			assert(_handlerPairs[identifier] == nil)
			_handlerPairs[identifier]	=	handler
		}
	}
	private func _processDeregistration(identifier: ObjectIdentifier) {
		if _isOnline() {
			_mappedAS!.deregister(identifier)
		} else {
			assert(_handlerPairs[identifier] != nil)
			_handlerPairs[identifier]	=	nil
		}
	}
	private func _applyTransactionWithFiltering(transaction: _InputSignal.Transaction) {
		let	muts	=	transaction.mutations.map(_filterMutation).filter({ $0 != nil }).map({ $0! })
		let	tran1	=	_OutputSignal.Transaction(mutations: muts)
		_mappedAS!.apply(tran1)
	}
	private func _filterMutation(m: _InputSignal.Transaction.Mutation) -> _OutputSignal.Transaction.Mutation? {
		switch (m.past, m.future) {
		case (nil,nil):		fatalError("Unsupported combination.")
		case (nil,_):		return	(m.identity, nil, map!(m.future!))
		case (_,nil):		return	(m.identity, map!(m.past!), nil)
		case (_,_):		return	(m.identity, map!(m.past!), map!(m.future!))
		}
	}
}





extension ArrayMappingArrayStorage {
	public var snapshot: [U] {
		get {
			return	_mappedAS!.snapshot
		}
	}
}











