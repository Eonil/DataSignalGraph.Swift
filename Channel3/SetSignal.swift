//
//  SetSignal.swift
//  Channel3
//
//  Created by Hoon H. on 2015/04/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

///	**WARNING**: Not tested yet.
public enum SetSignal<T: Hashable> {
	typealias	Snapshot	=	Set<T>
	typealias	Transaction	=	CollectionTransaction<T,()>
	case Initiation	(snapshot	: Snapshot)
	case Transition	(transaction: Transaction)
	case Termination(snapshot	: Snapshot)
}
extension SetSignal: CollectionSignalType {
	var initiation: Snapshot? {
		get {
			switch self {
			case .Initiation(snapshot: let s):		return	s
			default:								return	nil
			}
		}
	}
	var transition: Transaction? {
		get {
			switch self {
			case .Transition(transaction: let s):	return	s
			default:								return	nil
			}
		}
	}
	var termination: Snapshot? {
		get {
			switch self {
			case .Termination(snapshot: let s):		return	s
			default:								return	nil
			}
		}
	}
}
extension SetSignal {
	func apply(inout set: Set<T>?) {
		switch self {
		case .Initiation(let s):
			assert(set == nil, "Current array must be empty to apply initiation snapshot.")
			set		=	s
			
		case .Transition(let t):
			for m in t.mutations {
				switch (m.past != nil, m.future != nil) {
				case (false, true):
					//	Insert.
					set!.insert(m.identity)
					
				case (true, true):
					//	Update.
					//	Update is invalid in set collection.
					fallthrough
					
				case (true, false):
					//	Delete.
					set!.remove(m.identity)
					
				default:
					fatalError("Unsupported combination.")
				}
			}
			
		case .Termination(let s):
			assert(set != nil)
			assert(s.count == set!.count, "Current array must be equal to latest snapshot to apply termination.")
			set		=	nil
		}
	}
}



























