//
//  ChannelType.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/25.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public protocol ChannelType {
	typealias	Signal
	func register(identifier: ObjectIdentifier, handler: Signal->())
	func deregister(identifier: ObjectIdentifier)
}










