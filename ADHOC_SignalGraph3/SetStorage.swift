//
//  ArrayTransaction.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/25.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class SetStorage<T: Hashable>: ChannelType, CollectionTransactionApplicable {
	public typealias	Signal		=	CollectionSignal<Set<T>,T,()>
	
	///
	
	public init(_ snapshot: Set<T>) {
		_snapshot	=	snapshot
	}
	public var snapshot: Set<T> {
		get {
			return	_snapshot
		}
		set(v) {
			_castWillEnd(by: _endSnapshotTransaction())
			_snapshot	=	v
			_castDidBegin(by: _beginSnapshotTransaction())
		}
	}
	
	public func apply(transaction: Signal.Transaction) {
		_castWillEnd(by: transaction)
		snapshot.apply(transaction)
		_castDidBegin(by: transaction)
	}
	
	public func register(identifier: ObjectIdentifier, handler: Signal->()) {
		_signch.register(identifier, handler: handler)
		_castDidBegin(by: nil)
		
	}
	public func deregister(identifier: ObjectIdentifier) {
		_castWillEnd(by: nil)
		_signch.deregister(identifier)
	}
	
	///
	
	private let	_signch		=	SignalChannel<Signal>()
	private var	_snapshot	=	Set<T>()
	
	private func _castDidBegin(by transaction: Signal.Transaction?) {
		_signch.cast(Signal.DidBegin(state: { [weak self] in self!.snapshot}, by: transaction))
	}
	private func _castWillEnd(by transaction: Signal.Transaction?) {
		_signch.cast(Signal.WillEnd(state: { [weak self] in self!.snapshot}, by: transaction))
	}
	
	private func _beginSnapshotTransaction() -> Signal.Transaction {
		var	muts	=	Array<Signal.Transaction.Mutation>()
		map(snapshot, { muts.append(($0, nil, ())) })
		return	Signal.Transaction(mutations: muts)
	}
	private func _endSnapshotTransaction() -> Signal.Transaction {
		var	muts	=	Array<Signal.Transaction.Mutation>()
		map(snapshot, { muts.append(($0, (), nil)) })
		return	Signal.Transaction(mutations: muts)
	}
}





extension SetStorage {
	public func insert(member: T) {
		let	tran	=	CollectionTransaction(mutations: [(member, nil, ())])
		apply(tran)
	}
	public func remove(member: T) {
		let	tran	=	CollectionTransaction(mutations: [(member, (), nil)])
		apply(tran)
	}
}















