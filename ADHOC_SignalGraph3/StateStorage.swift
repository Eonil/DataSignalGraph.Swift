//
//  StateStorage.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/25.
//  Copyright (c) 2015 Eonil. All rights reserved.
//



public class StateStorage<T>: ChannelType {
	public typealias	Signal		=	StateSignal<T>
	
	public init(_ state: T) {
		self.state	=	state
	}
	deinit {
	}
	
	public var state: T {
		willSet {
			_castWillEnd()
		}
		didSet {
			_castDidBegin()
		}
	}
	
	public func register(identifier: ObjectIdentifier, handler: Signal->()) {
		_signch.register(identifier, handler: handler)
		_castDidBegin()
		
	}
	public func deregister(identifier: ObjectIdentifier) {
		_castWillEnd()
		_signch.deregister(identifier)
	}
	
	///
	
	private let	_signch		=	SignalChannel<Signal>()
	
	private func _castDidBegin() {
		_signch.cast(StateSignal<T>.DidBegin(state: { [weak self] in self!.state}))
	}
	private func _castWillEnd() {
		_signch.cast(StateSignal<T>.WillEnd(state: { [weak self] in self!.state}))
	}
}


