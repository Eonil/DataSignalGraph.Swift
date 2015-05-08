//
//  SignalFilter.swift
//  Channel3
//
//  Created by Hoon H. on 2015/05/08.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

class SignalFilter<T> {
	///	:param:		filter
	///				Returns `true` is the signal can be passed to next node.
	///				Returns `false` if the signal should not be passed to next node.
	///
	init(_ filter: T->Bool) {
		self.filter		=	filter
		monitor.handler	=	{ [weak self] v in
			if self!.filter(v) {
				self!.dispatcher.signal(v)
			}
		}
	}
	var	sensor: SignalSensor<T> {
		get {
			return	monitor
		}
	}
	var emitter: SignalEmitter<T> {
		get {
			return	dispatcher
		}
	}
	
	////
	
	private let	monitor		=	SignalMonitor<T>({ _ in })
	private let	dispatcher	=	SignalDispatcher<T>()
	private let	filter		:	T->Bool
}