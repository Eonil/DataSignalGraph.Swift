//
//  AggregationCollectionStorage.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/06/22.
//  Copyright (c) 2015 Eonil. All rights reserved.
//







///	You cannot access contained state of this storage while this storage is not
///	registered to a source storage.
public class DictionaryFilteringDictionaryStorage<K: Hashable, V>: SignalSensor<DictionaryStorage<K,V>.Definition.Signal>, StateStorageType {
	public typealias	Definition	=	DictionaryStorage<K,V>.Definition
	
	public override init() {
		super.init()
	}
	//	public convenience init(filter: ((K,V)->Bool)) {
	//		self.init()
	//		self.filter	=	filter
	//	}
	deinit {
		filter	=	nil
	}
	
	///
	
	public var snapshot: Definition.Snapshot {
		get {
			precondition(_registered == true, "You can access contained state of this storage only while this storage is registered to a source storage.")
			return	_filtered!.snapshot
		}
	}
	///	Replacing filter function will trigger complete reloading of
	///	whole dataset in this storage.
	public var filter: ((K,V)->Bool)? {
		willSet {
			if filter != nil {
//				_disconnect()
			}
		}
		didSet {
			if filter != nil {
//				_connect()
			}
		}
	}
	
	///
	
	public func register(sensor: SignalSensor<Definition.Signal>) {
		_dispatcher.register(sensor)
	}
	public func deregister(sensor: SignalSensor<Definition.Signal>) {
		_dispatcher.deregister(sensor)
	}
	final func register(monitor: StateMonitor<Definition>) {
		_dispatcher.register(monitor)
	}
	final func deregister(monitor: StateMonitor<Definition>) {
		_dispatcher.deregister(monitor)
	}
	
	///
	
	@availability(*,unavailable)
	override var handler: (Definition.Signal->())? {
		willSet {
			fatalError("Using of this property has been prohibited.")
		}
	}
	override func transfer(signal: () -> Definition.Signal) {
		super.transfer(signal)
		_process(signal())
	}
	
	///
	
	///	Internally, contained state is an empty dictionary when this storage is unregistered.
	///	It will be filled with filtered result by signals from source storage while this storage is registered to there.
	///
	///
	
	private let	_sensor		=	SignalSensor<Definition.Signal>()
	private let	_dispatcher	=	SignalDispatcher<Definition.Signal>()
	private var	_filtered	:	DictionaryStorage<K,V>?
	private var	_registered	=	false
	
	private func _process(signal: Definition.Signal) {
		switch signal {
		case .DidInitiate:
			_registered	=	true
		case .DidBegin(state: let snapshot, by: let reason):
			_didBegin(snapshot(), by: reason())
		case .WillEnd(state: let snapshot, by: let reason):
			_willEnd(snapshot(), by: reason())
		case .WillTerminate:
			_registered	=	false
		}
	}
	
	private func _didBegin(state: Definition.Snapshot, by: Definition.Signal.Reason) {
		_assertFilterExistence()
		switch by {
		case .StateMutation(let transaction):
			_applyTransactionWithFiltering(transaction())
		case .RegisteringSensor(_):
			_sensor.handler	=	{ [weak self] in self!._dispatcher.transfer($0) }
			_filtered	=	DictionaryStorage(_filterSnapshot(state))
			_filtered!.register(_sensor)
			
		case .DeregisteringSensor(_):
			break
		}
	}
	private func _willEnd(state: Definition.Snapshot, by: Definition.Signal.Reason) {
		_assertFilterExistence()
		switch by {
		case .StateMutation(let transaction):
			break
		case .RegisteringSensor(_):
			_filtered!.deregister(_sensor)
			_filtered	=	nil
			_sensor.handler	=	nil
			
		case .DeregisteringSensor(_):
			break
		}
	}
	private func _filterSnapshot(snapshot: Definition.Snapshot) -> Definition.Snapshot {
		var	snapshot1	=	[K:V]()
		for (k,v) in snapshot {
			if filter!(k,v) {
				snapshot1[k]	=	v
			}
		}
		return	snapshot
	}
	private func _applyTransactionWithFiltering(transaction: Definition.Transaction) {
		_assertFilterExistence()
		let	muts1	=	transaction.mutations
		let	muts2	=	_filterMutations(muts1)
		let	tran2	=	Definition.Transaction(mutations: muts2)
		_filtered!.apply(tran2)
	}
	private func _filterMutations(muts: [Definition.Transaction.Mutation]) -> [Definition.Transaction.Mutation] {
		_assertFilterExistence()
		var	muts1	=	Array<Definition.Transaction.Mutation>()
		for mut in  muts {
			switch (mut.past, mut.future) {
			case (nil, nil):
				fatalError("Unsupported combination.")

			case (nil, _):
				let	pass	=	filter!((mut.identity, mut.future!))
				if pass {
					muts1.append(mut)
				}
				
			case (_, _):
				let	decomp1	=	(mut.identity, mut.past!, nil) as Definition.Transaction.Mutation
				let	decomp2	=	(mut.identity, nil, mut.future!) as Definition.Transaction.Mutation
				let	pass1	=	filter!(decomp1.identity, decomp1.past!)
				let	pass2	=	filter!(decomp2.identity, decomp1.future!)
				if pass1 {
					muts1.append(decomp1)
				}
				if pass2 {
					muts1.append(decomp1)
				}
				
			case (_, nil):
				let	pass	=	filter!((mut.identity, mut.past!))
				if pass {
					muts1.append(mut)
				}
			}
		}
		return	muts1
	}
	private func _assertFilterExistence() {
		assert(filter != nil, "You must set a filter before registering this storage to a source storage.")
	}
	
}

public class DictionarySortingArrayStorage<K: Hashable, V>: StateMonitor<DictionaryStorage<K,V>.Definition>, StateStorageType {
	public typealias	Definition	=	ArrayStorage<V>.Definition
	
	public init(_ snapshot: Definition.Snapshot) {
		self.snapshot	=	snapshot
	}
	public var snapshot: Definition.Snapshot
}

public class ValueMappingArrayStorage<T,U>: StateMonitor<ArrayStorage<T>.Definition>, StateStorageType {
	public typealias	Definition	=	ArrayStorage<U>.Definition
	
	public init(_ snapshot: Definition.Snapshot) {
		self.snapshot	=	snapshot
	}
	public var snapshot: Definition.Snapshot
}


