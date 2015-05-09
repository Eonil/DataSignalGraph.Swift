//
//  DictionarySignal.swift
//  Channel3
//
//  Created by Hoon H. on 2015/04/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//


public enum DictionarySignal<K: Hashable,V> {
	typealias	Snapshot	=	[K:V]
	typealias	Transaction	=	CollectionTransaction<K,V>
	case Initiation	(snapshot	: Snapshot)
	case Transition	(transaction: Transaction)
	case Termination(snapshot	: Snapshot)
}
extension DictionarySignal: CollectionSignalType {
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
//struct DictionaryTransaction<K: Hashable,V> {
//	var	mutations	:	[DictionaryMutation<K,V>]
//	
//}
//struct DictionaryMutation<K: Hashable,V> {
//	var	operation	:	DictionaryOperation
//	var	past		:	(K,V)
//	var	future		:	(K,V)
//}
//typealias DictionaryOperation	=	IndexCollectionOperation




//extension Dictionary: SignalApplicableCollectionType {
//}




extension Dictionary {
	mutating func apply(s: DictionarySignal<Key,Value>) {
		switch s {
		case .Initiation(snapshot: let s):
			assert(self.count == 0, "Current array must be empty to apply initiation snapshot.")
			self	=	s
			
		case .Transition(transaction: let t):
			for m in t.mutations {
				switch (m.past != nil, m.future != nil) {
				case (false, true):
					//	Insert.
					assert(self[m.identity] == nil, "There should be no existing value for the key `\(m.identity)`, but there's an existing value `\(self[m.identity]!)` for the key.")
					self[m.identity]	=	m.future
					
				case (true, true):
					//	Update.
					assert(self[m.identity] != nil, "There should be an existing value for the key `\(m.identity)`, but there's none.")
					self[m.identity]	=	m.future
					
				case (true, false):
					assert(self[m.identity] != nil, "There should be an existing value for the key `\(m.identity)`, but there's none.")
					//	Delete.
					self.removeValueForKey(m.identity)
					
				default:
					fatalError("Unsupported combination.")
				}
			}
			
		case .Termination(snapshot: let s):
			assert(s.count == self.count, "Current array must be equal to latest snapshot to apply termination.")
			self	=	Dictionary()
		}
	}
}





























