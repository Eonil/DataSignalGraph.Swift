//
//  StateProcessor.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/05/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class StateHandler<T> {
	
	public init() {
		monitor.handler	=	{ [unowned self] s in
			switch s {
			case .Initiation(let s):	self.didInitiate(s())
			case .Transition(let s):	self.didChange(s())
			case .Termination(let s):	self.willTerminate(s())
			}
		}
	}
	public var sensor: SignalSensor<ValueSignal<T>> {
		get {
			return	monitor
		}
	}
	
	public var	didInitiate:		((T)->())	=	NOOP
	public var	willChange:			((T)->())	=	NOOP
	public var	didChange:			((T)->())	=	NOOP
	public var	willTerminate:		((T)->())	=	NOOP
	
	public var	handlers:			(didInitiate: (T)->(), willChange: (T)->(), didChange: (T)->(), willTerminate: (T)->()) {
		get {
			return	(didInitiate, willChange, didChange, willTerminate)
		}
		set(v) {
			didInitiate		=	v.didInitiate
			willChange		=	v.willChange
			didChange		=	v.didChange
			willTerminate	=	v.willTerminate
		}
	}
	
	////
	
	private let	monitor	=	SignalMonitor<ValueSignal<T>>()
}

private func NOOP<T>(T) {}