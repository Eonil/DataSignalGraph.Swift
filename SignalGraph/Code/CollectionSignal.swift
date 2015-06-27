//
//  CollectionSignal.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/25.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public enum CollectionSignal<C: CollectionType, K: Hashable, V> {
	public typealias	Transaction	=	CollectionTransaction<K,V>
	
	///	Collection became a new `state` `by` the transaction.
	///	`by` is `nil` if this is triggered by observer registration.
	///
	case DidBegin(state: ()->C, by: Transaction?)
	
	///	Collection will become a new `state` `by` the transaction.
	///	`by` is `nil` if this is triggered by observer deregistration.
	///
	case WillEnd(state: ()->C, by: Transaction?)
	
}



extension CollectionSignal {
	var isInitiation: Bool {
		get {
			switch self {
			case .DidBegin(let _, let by):		return	by == nil
			default:				return	false
			}
		}
	}
	var isTermination: Bool {
		get {
			switch self {
			case .WillEnd(let _, let by):		return	by == nil
			default:				return	false
			}
		}
	}
	var stateSnapshot: C? {
		get {
			switch self {
			case .DidBegin(let state, let _):	return	state()
			case .WillEnd(let state, let _):	return	state()
			default:				return	nil
			}
		}
	}
	var byTransaction: CollectionTransaction<K,V>? {
		get {
			switch self {
			case .DidBegin(let _, let by):		return	by
			case .WillEnd(let _, let by):		return	by
			default:				return	nil
			}
		}
	}
}







