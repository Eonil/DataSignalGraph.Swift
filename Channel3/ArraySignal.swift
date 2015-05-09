//
//  ArraySignal.swift
//  Channel3
//
//  Created by Hoon H. on 2015/04/08.
//  Copyright (c) 2015 Eonil. All rights reserved.
//



public enum ArraySignal<T> {
	public typealias	Snapshot	=	[T]
	public typealias	Transaction	=	CollectionTransaction<Array<T>.Index,T>
	case Initiation	(snapshot: Snapshot)
	case Transition	(transaction: Transaction)
	case Termination(snapshot: Snapshot)
}
//extension ArraySignal: CollectionSignalType {
//	var initiation: Snapshot? {
//		get {
//			switch self {
//			case .Initiation(snapshot: let s):		return	s
//			default:								return	nil
//			}
//		}
//	}
//	var transition: Transaction? {
//		get {
//			switch self {
//			case .Transition(transaction: let s):	return	s
//			default:								return	nil
//			}
//		}
//	}
//	var termination: Snapshot? {
//		get {
//			switch self {
//			case .Termination(snapshot: let s):		return	s
//			default:								return	nil
//			}
//		}
//	}
//}
extension ArraySignal {
	func apply(inout a: [T]?) {
		switch self {
		case .Initiation(snapshot: let s):
			assert(a == nil, "Target array must be nil to apply initiation snapshot.")
			a	=	s
			
		case .Transition(transaction: let t):
			assert(a != nil)
			for m in t.mutations {
				switch (m.past != nil, m.future != nil) {
				case (false, true):
					//	Insert.
					a!.insert(m.future!, atIndex: m.identity)
					
				case (true, true):
					//	Update.
					a![m.identity]	=	m.future!
					
				case (true, false):
					//	Delete.
					a!.removeAtIndex(m.identity)
					
				default:
					fatalError("Unsupported combination.")
				}
			}
			
		case .Termination(snapshot: let s):
			assert(a != nil)
			assert(s.count == a!.count, "Current array must be equal to latest snapshot to apply termination.")
			a	=	nil
		}
	}
}
















//extension Array {
//	mutating func apply(s: ArraySignal<Element>) {
//		switch s {
//		case .Initiation(snapshot: let s):
//			assert(self.count == 0, "Current array must be empty to apply initiation snapshot.")
//			self	=	s
//			
//		case .Transition(transaction: let t):
//			for m in t.mutations {
//				switch (m.past != nil, m.future != nil) {
//				case (false, true):
//					//	Insert.
//					insert(m.future!, atIndex: m.identity)
//					
//				case (true, true):
//					//	Update.
//					self[m.identity]	=	m.future!
//					
//				case (true, false):
//					//	Delete.
//					removeAtIndex(m.identity)
//					
//				default:
//					fatalError("Unsupported combination.")
//				}
//			}
//			
//		case .Termination(snapshot: let s):
//			assert(s.count == self.count, "Current array must be equal to latest snapshot to apply termination.")
//			self	=	Array()
//		}
//	}
//}
















