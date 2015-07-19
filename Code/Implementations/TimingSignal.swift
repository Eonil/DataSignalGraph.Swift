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
	case DidBegin(()->StateSignal<S,T>)
	case WillEnd(()->StateSignal<S,T>)
}


public extension TimingSignal {
	///	For Swift 1.x.
	static func HOTFIX_DidBegin(subsignal: StateSignal<S,T>) -> TimingSignal {
		return	DidBegin({subsignal})
	}
	///	For Swift 1.x.
	static func HOTFIX_WillEnd(subsignal: StateSignal<S,T>) -> TimingSignal {
		return	WillEnd({subsignal})
	}
}


