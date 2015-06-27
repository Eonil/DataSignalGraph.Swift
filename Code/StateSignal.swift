//
//  StateSignal.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/25.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public enum StateSignal<T> {
	case DidBegin(state: ()->T)
	case WillEnd(state: ()->T)
}
