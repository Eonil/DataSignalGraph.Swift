//
//  AsynchronousSignal.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/07/19.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

struct AsynchronousSignal<S,T: TransactionType> {
	public typealias	Snapshot	=	S
	public typealias	Transaction	=	T
	public typealias	Cause		=	StateSignalingCause<S,T>

	public var 		state		:	Snapshot
	public var		by		:	Cause
}