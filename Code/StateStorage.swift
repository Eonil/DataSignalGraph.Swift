//
//  StateStorage.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/25.
//  Copyright (c) 2015 Eonil. All rights reserved.
//



public class StateStorage<T> {
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

	public var channel: SignalChannel<Signal> {
		get {
			return	_sigst.channel
		}
	}

	///

	private let	_sigst		=	SignalStation<Signal>()

	private func _castDidBegin() {
		_sigst.channel.cast(StateSignal<T>.DidBegin(state: { [weak self] in self!.state}))
	}
	private func _castWillEnd() {
		_sigst.channel.cast(StateSignal<T>.WillEnd(state: { [weak self] in self!.state}))
	}
}

///	Temporary for Swift 1.x.
///	Remove at Swift 2.x.
public extension StateStorage {
	public var snapshot: T {
		get {
			return	state
		}
	}
}


