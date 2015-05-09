//
//  ValueSignal.swift
//  Channel3
//
//  Created by Hoon H. on 2015/05/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public enum ValueSignal<T> {
	typealias	Snapshot	=	()->T
	case Initiation	(Snapshot)
	case Transition	(Snapshot)
	case Termination(Snapshot)
}
//extension ValueSignal {
//	var initiation: Snapshot? {
//		get {
//			switch self {
//			case .Initiation(snapshot: let s):		return	s
//			default:								return	nil
//			}
//		}
//	}
//	var transition: Snapshot? {
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
//
