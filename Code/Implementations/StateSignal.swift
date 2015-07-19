//
//  AsynchronousSignal.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/07/19.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

///	Parameters are wrapped in a closure to avoid bugs in Swift 1.x.
public enum StateSignal<S,T: TransactionType> {
	case Session(()->S)
	case Transaction(()->T)
	case Mutation(()->T.Mutation)
}

public extension StateSignal {
	///	For Swift 1.x.
	static func HOTFIX_Session(s: S) -> StateSignal {
		return	Session({s})
	}
	///	For Swift 1.x.
	static func HOTFIX_Transaction(s: T) -> StateSignal {
		return	Transaction({s})
	}
	///	For Swift 1.x.
	static func HOTFIX_Mutation(m: T.Mutation) -> StateSignal {
		return	Mutation({m})
	}
}






