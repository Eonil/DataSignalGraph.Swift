//
//  DictionaryFilteringDictionaryStorage.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/05/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//



///	Manages a subset dictionary by filtering a virtual dictionary derived from 
///	dictionary signal.
///
///	
public class DictionaryFilteringDictionaryStorage<K: Hashable,V>: StorageType {
	
	///
	///	:param:		filter
	///			A filter function to filter key-value pair subset.
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
	public init(_ filter: (K,V) -> Bool) {
		_filter			=	filter
		_monitor.handler	=	{ [unowned self] s in self._apply(s) }
	}
	
	public var sensor: SignalSensor<DictionarySignal<K,V>> {
		get {
			return	_monitor
		}
	}
	public var state: [K:V] {
		get {
			return	_replication.state
		}
	}
	public var emitter: SignalEmitter<DictionarySignal<K,V>> {
		get {
			return	_replication.emitter
		}
	}
	
	////
	
	private let	_monitor	=	SignalMonitor<DictionarySignal<K,V>>()
	private let	_filter		:	(K,V) -> Bool
	private let	_replication	=	ReplicatingDictionaryStorage<K,V>()
	
	private var _editor: DictionaryStorageEditor<K,V> {
		get {
			return	DictionaryStorageEditor(_replication)
		}
	}
	
	private func _apply(s: DictionarySignal<K,V>) {
		switch s {
		case .Initiation(let s):
			_replication.sensor.signal(DictionarySignal.Initiation(snapshot: [:]))
			for e in s {
				if _filter(e) {
					insert(e)
				}
			}
		case .Transition(let s):
			for m in s.mutations {
				let	ts	=	(m.past == nil, m.future == nil)
				switch ts {
				case (true, false):
					if _filter(m.identity, m.future!) {
						insert(m.identity, m.future!)
					}
					
				case (false, false):
					let	fs	=	(_filter(m.identity, m.past!), _filter(m.identity, m.future!))
					switch fs {
					case (false, true):
						//	Past value was filtered out.
						//	Future value does not.
						//	So treat it as an new insert.
						insert(m.identity, m.future!)
						
					case (true, true):
						//	Both of past and future values
						//	are not filtered out.
						//	This is just a plain update.
						update(m.identity, m.future!)
						
					case (true, false):
						//	Past value was not filtered out.
						//	Future value will be filtered out.
						//	Treat it as a delete.
						delete(m.identity)
						
					case (false, false):
						//	Both of past and future values 
						//	are filtered out.
						//	Just ignore it.
						()
						
					default:
						fatalError("Unsupported filtering state combination `\(fs)`.")
						
					}
				case (false, true):
					if _filter(m.identity, m.past!) {
						delete(m.identity)
					}
					
				default:
					fatalError("Unsupported value transiation entry combination `\(ts)`.")
				}
			}
		case .Termination(let s):
			//	`s` is an unfiltered snapshot, so likely to have more elements
			//	then `_replication.state`.
			for e in s {
				if _filter(e) {
					delete(e.0)
				}
			}
			assert(_replication.state.count == 0)
			_replication.sensor.signal(DictionarySignal.Termination(snapshot: [:]))
		}
	}
	
	private func insert(e: (K,V)) {
		assert(_editor[e.0] == nil, "There should be no existing value for the key `\(e.0)`.")
		var	ed	=	_editor
		ed[e.0]		=	e.1
	}
	private func update(e: (K,V)) {
		var	ed	=	_editor
		ed[e.0]		=	e.1
	}
	private func delete(e: (K)) {
		var	ed	=	_editor
		ed.removeValueForKey(e)
	}
}
















