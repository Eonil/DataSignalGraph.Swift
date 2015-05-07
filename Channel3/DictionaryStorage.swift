//
//  DictionaryStorage.swift
//  Channel3
//
//  Created by Hoon H. on 2015/05/06.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class DictionaryStorage<K,V where K: Hashable>: StorageType {
	
	public private(set) var	state: [K:V] = [:]
	
	public var emitter: SignalEmitter<DictionarySignal<K,V>> {
		get {
			return	dispatcher
		}
	}
	
	////
	
	private init() {
	}
	
	private let	dispatcher	=	SignalDispatcher<DictionarySignal<K,V>>()
}

///	Collection containers cannot have non-empty initial state because
///	it's hard to guarantee state integrity if there are many mutators.
///	Always Having empty initial state will make everything a lot simpler.
public final class DictionaryReplication<K,V where K: Hashable>: DictionaryStorage<K,V>, ReplicationType {
	
	public override init() {
		super.init()
		monitor.handler	=	{ [weak self] s in
			self!.state.apply(s)
			self!.dispatcher.signal(s)
		}
	}
	
	public var sensor: SignalSensor<DictionarySignal<K,V>> {
		get {
			return	monitor
		}
	}
	
	////
	
	private let	monitor		=	SignalMonitor<DictionarySignal<K,V>>({ _ in })
}
