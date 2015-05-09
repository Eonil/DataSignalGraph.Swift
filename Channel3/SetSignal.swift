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

/////	Represents an atomic transaction.
/////	Mutations are order-dependent to avoid diff cost and ambiguity.
//struct SetTransaction<T: Hashable> {
//	var	mutations	:	[SetMutation<T>]
//}
//struct SetMutation<T: Hashable> {
//	var	operation	:	SetOperation
//	var	value		:	T?
//}
//typealias	SetOperation	=	IndexlessCollectionOperation










//extension Set: SignalApplicableCollectionType {
//}




extension Set {
	mutating func apply(s: SetSignal<Element>) {
		switch s {
		case .Initiation(snapshot: let s):
			assert(self.count == 0, "Current array must be empty to apply initiation snapshot.")
			self	=	s
			
		case .Transition(transaction: let t):
			for m in t.mutations {
				switch (m.past != nil, m.future != nil) {
				case (false, true):
					//	Insert.
					self.insert(m.identity)
					
				case (true, true):
					//	Update.
					//	Update is invalid in set collection.
					fallthrough
					
				case (true, false):
					//	Delete.
					self.remove(m.identity)
					
				default:
					fatalError("Unsupported combination.")
				}
			}
			
		case .Termination(snapshot: let s):
			assert(s.count == self.count, "Current array must be equal to latest snapshot to apply termination.")
			self	=	Set()
		}
	}
}











