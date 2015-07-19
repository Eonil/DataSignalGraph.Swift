//
//  TimingSignal.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/01.
//  Copyright © 2015 Eonil. All rights reserved.
//

///	Parameters are wrapped in a closure to avoid bugs in Swift 1.x.
public enum TimingSignal<S,T: TransactionType>: TimingSignalType {
	public typealias	Snapshot	=	S
	public typealias	Transaction	=	T
	public typealias	Cause		=	StateSignalingCause<S,T>
	case DidBegin(StateSignal<S,T>)
	case WillEnd(StateSignal<S,T>)
}
///	Parameters are wrapped in a closure to avoid bugs in Swift 1.x.
public enum StateSignalingCause<S,T: TransactionType> {
	case Session(()->S)
	case Transaction(()->T)
	case Mutation(()->T.Mutation)
}



public extension TimingSignal {
	///	For Swift 1.x.
	static func HOTFIX_DidBegin(state: Snapshot, by: Cause) -> TimingSignal {
		return	DidBegin(StateSignal(state: state, by: by))
	}
	///	For Swift 1.x.
	static func HOTFIX_WillEnd(state: Snapshot, by: Cause) -> TimingSignal {
		return	WillEnd(StateSignal(state: state, by: by))
	}
}
public extension StateSignalingCause {
	///	For Swift 1.x.
	static func HOTFIX_Session(s: S) -> StateSignalingCause {
		return	Session({s})
	}
	///	For Swift 1.x.
	static func HOTFIX_Transaction(s: T) -> StateSignalingCause {
		return	Transaction({s})
	}
	///	For Swift 1.x.
	static func HOTFIX_Mutation(m: T.Mutation) -> StateSignalingCause {
		return	Mutation({m})
	}
}






