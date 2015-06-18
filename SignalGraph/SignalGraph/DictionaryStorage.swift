//
//  DictionaryStorage.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/05/06.
//  Copyright (c) 2015 Eonil. All rights reserved.
//



public class DictionaryStorage<K,V where K: Hashable>: StorageType {
	public var state: [K:V] {
		get {
			fatalError()
		}
	}
	
	public var emitter: SignalEmitter<DictionarySignal<K,V>> {
		get {
			fatalError()
		}
	}
	
	///
	
	private init() {
	}
}


public class EditableDictionaryStorage<K: Hashable,V>: DictionaryStorage<K,V> {
	public init(_ state: Dictionary<K,V> = [:]) {
		super.init()
		_replication.sensor.signal(DictionarySignal.Initiation(snapshot: state))
	}
	deinit {
		_replication.sensor.signal(DictionarySignal.Termination(snapshot: state))
		//	We don't need to erase owned current state. Because
		//	users must already been removed all sensors from emitter.
		//	Emitter asserts no registered sensors when `deinit`ializes.
	}
	
	public override var state: [K:V] {
		get {
			return	_replication.state
		}
	}
	
	///
	
	private let	_replication	=	ReplicatingDictionaryStorage<K,V>()
}
extension DictionaryStorageEditor {
	public init(_ storage: EditableDictionaryStorage<K,V>) {
		self.init(storage._replication)
	}
}
extension EditableDictionaryStorage {
	public var count: Int {
		get {
			return	editor.count
		}
	}
	
	public subscript(key: K) -> V? {
		get {
			return	editor[key]
		}
		set(v) {
			if v == nil {
				editor.removeValueForKey(key)
			} else {
				editor[key]	=	v!
			}
		}
	}
	
	public func removeValueForKey(key: K) -> V? {
		return	editor.removeValueForKey(key)
	}
	public func removeAll() {
		editor.removeAll()
	}
	
	public var keys: LazyForwardCollection<MapCollectionView<[K : V], K>> {
		get {
			return	state.keys
		}
	}
	public var values: LazyForwardCollection<MapCollectionView<[K : V], V>> {
		get {
			return	state.values
		}
	}
	
	///
	
	///	Hacky tricky solution.
	private var editor: DictionaryStorageEditor<K,V> {
		get {
			return	DictionaryStorageEditor(_replication)
		}
		set(v) {
			assert(v.storage === _replication)
		}
	}
}









































///	A storage that provides indirect signal based mutator.
///
///	Initial state of a state-container is undefined, and you should not access
///	them while this contains is not bound to a signal source.
public class ReplicatingDictionaryStorage<K,V where K: Hashable>: DictionaryStorage<K,V>, ReplicationType {
	public override init() {
		super.init()
		_monitor.handler	=	{ [unowned self] s in self._apply(s) }
		_dispatcher.owner	=	self
	}
	
	public override var state: [K:V] {
		get {
			return	_pairs!
		}
	}
	public var sensor: SignalSensor<DictionarySignal<K,V>> {
		get {
			return	_monitor
		}
	}
	public override var emitter: SignalEmitter<DictionarySignal<K,V>> {
		get {
			return	_dispatcher
		}
	}
	
	////
	
	private var	_pairs		:	[K:V]?
	private let	_monitor	=	SignalMonitor<DictionarySignal<K,V>>({ _ in })
	private let	_dispatcher	=	_ReplicatingDictionaryStorageSignalDispatcher<K,V>()
	
	private func _apply(signal: DictionarySignal<K,V>) {
		signal.apply(&_pairs)
		_dispatcher.signal(signal)
	}
}

private final class _ReplicatingDictionaryStorageSignalDispatcher<K: Hashable,V>: SignalDispatcher<DictionarySignal<K,V>> {
	weak var owner: ReplicatingDictionaryStorage<K,V>?
	override func register(sensor: SignalSensor<DictionarySignal<K,V>>) {
		Debugging.EmitterSensorRegistration.assertRegistrationOfStatefulChannelingSignaling((self, sensor))
		super.register(sensor)
		if let _ = owner!._pairs {
			sensor.signal(DictionarySignal.Initiation(snapshot: owner!.state))
		}
	}
	override func deregister(sensor: SignalSensor<DictionarySignal<K,V>>) {
		Debugging.EmitterSensorRegistration.assertDeregistrationOfStatefulChannelingSignaling((self, sensor))
		super.deregister(sensor)
		if let _ = owner!._pairs {
			sensor.signal(DictionarySignal.Termination(snapshot: owner!.state))
		}
	}
}
















public class MonitoringDictionaryStorage<K,V where K: Hashable>: ReplicatingDictionaryStorage<K,V> {
	public typealias	SignalHandler		=	DictionarySignal<K,V> -> ()
	public var		willApplySignal		:	SignalHandler?
	public var		didApplySignal		:	SignalHandler?
	
	///
	
	private override func _apply(signal: DictionarySignal<K,V>) {
		willApplySignal?(signal)
		super._apply(signal)
		didApplySignal?(signal)
	}
}



///	Unlike `MonitoringDictionaryStorage`, this provides you event handlers for
///	each element events liks `insert` or `delete`.
public class TrackingDictionaryStorage<K: Hashable, V>: ReplicatingDictionaryStorage<K,V> {
	public typealias	ElementHandler		=	CollectionTransaction<K,V>.Mutation -> ()
	public var		willInsert		:	ElementHandler?
	public var		didInsert		:	ElementHandler?
	public var		willUpdate		:	ElementHandler?
	public var		didUpdate		:	ElementHandler?
	public var		willDelete		:	ElementHandler?
	public var		didDelete		:	ElementHandler?
	
	///
	
	private override func _apply(signal: DictionarySignal<K,V>) {
		switch signal {
		case .Initiation(let snapshot):
			for (k,v) in snapshot {
				willInsert?((k,nil,v))
			}
			_pairs		=	snapshot
			for (k,v) in snapshot {
				didInsert?((k,nil,v))
			}
		case .Transition(let transaction):
			for mutation in transaction.mutations {
				_apply(mutation)
			}
		case .Termination(let snapshot):
			for (k,v) in snapshot {
				willDelete?((k,v,nil))
			}
			_pairs		=	nil
			for (k,v) in snapshot {
				didDelete?((k,v,nil))
			}
		}
	}
	
	private func _apply(mutation: CollectionTransaction<K,V>.Mutation) {
		switch (mutation.past != nil, mutation.future != nil) {
		case (false, true):
			//	Insert.
			willInsert?(mutation)
			_pairs![mutation.identity]	=	mutation.future!
			didInsert?(mutation)
			
		case (true, true):
			//	Update.
			willUpdate?(mutation)
			_pairs![mutation.identity]	=	mutation.future!
			didUpdate?(mutation)
			
		case (true, false):
			//	Delete.
			willDelete?(mutation)
			_pairs!.removeValueForKey(mutation.identity)
			didDelete?(mutation)
			
		default:
			fatalError("Unsupported combination `\(mutation)` cannot be processed.")
		}
	}
}

























