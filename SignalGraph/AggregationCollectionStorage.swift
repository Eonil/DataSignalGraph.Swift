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
			return	_storage.snapshot
		}
	}
	///	Replacing filter function will trigger complete reloading of
	///	whole dataset in this storage.
	public var filter: ((K,V)->Bool)? {
		willSet {
			if filter != nil {
				_disconnect()
			}
		}
		didSet {
			if filter != nil {
				_connect()
			}
		}
	}
	
	///
	
	public func register(sensor: SignalSensor<Definition.Signal>) {
		_storage.register(sensor)
	}
	public func deregister(sensor: SignalSensor<Definition.Signal>) {
		_storage.deregister(sensor)
	}
	final func register(monitor: StateMonitor<Definition>) {
		_storage.register(monitor)
	}
	final func deregister(monitor: StateMonitor<Definition>) {
		_storage.deregister(monitor)
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
	
	private let	_storage	=	DictionaryStorage<K,V>([:])
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
	
	private func _didBegin(state: Definition.Snapshot, by: StateSessionNotificationReason<Definition>) {
		_assertFilterExistence()
		_storage.apply { (inout state: Definition.Snapshot) -> () in
			switch by {
			case .StateMutation(by: let transaction):
				_applyTransaction(transaction())
				
			default:
				break
			}
		}
	}
	private func _willEnd(state: Definition.Snapshot, by: StateSessionNotificationReason<Definition>) {
		_assertFilterExistence()
		
	}
	private func _assertFilterExistence() {
		assert(filter != nil, "You must set a filter before registering this storage to a source storage.")
	}
	
	private func _applyTransaction(transaction: Definition.Transaction) {
		for mut in transaction.mutations {
			switch (mut.past, mut.future) {
			case (nil, nil):
				break
			case (nil, _):
				let	pass	=	filter!((mut.identity, mut.future!))
				if pass {
					
				}
			case (_, _):
			case (_, nil):
			}
			mut.identity
		}
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


