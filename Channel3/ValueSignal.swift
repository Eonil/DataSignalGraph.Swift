//
//  ValueSignal.swift
//  Channel3
//
//  Created by Hoon H. on 2015/05/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public enum ValueSignal<T> {
	//	TODO:	Remove closure and convert into bare value
	//			after compiler support it.
	typealias	Snapshot	=	()->T
	case Initiation	(Snapshot)
	case Transition	(Snapshot)
	case Termination(Snapshot)
}

