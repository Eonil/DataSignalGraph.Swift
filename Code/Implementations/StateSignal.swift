//
//  AsynchronousSignal.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/07/19.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

///	**WARNING**
///	This must be a `struct`, but written with `class` due to a
///	bug in Swift 1.x compiler.
///	So NEVER depend on referential identity of this object.
///
public final class StateSignal<S,T: TransactionType> {
	public typealias	Snapshot	=	S
	public typealias	Transaction	=	T
	public typealias	Cause		=	StateSignalingCause<S,T>

//	public var 		state		:	Snapshot
	public var		by		:	Cause

	public init(state: Snapshot, by: Cause) {
//		self.state	=	state
		self.by		=	by
	}
}