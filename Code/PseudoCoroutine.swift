//
//  PseudoCoroutine.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/06/27.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation






enum Continuation {
	case None
	case Continue((_: PseudoCoroutine)->Continuation)
}
extension Continuation: NilLiteralConvertible {
	init(nilLiteral: ()) {
		self	=	.None
	}
	init(_ block: (_: PseudoCoroutine)->Continuation) {
		self	=	.Continue(block)
	}
}
//postfix func !(c: Continuation) -> ((_: PseudoCoroutine)->Continuation) {
//	switch c {
//	case .None:			fatalError("Cannot unwrap the continuation `\(c)`.")
//	case .Continue(let program):	return	program
//	}
//}





///	Something like Bolts' `BFTask` with no frills.
class PseudoCoroutine {
	typealias	Block	=	(_: PseudoCoroutine)->Continuation

	static func spawn(block: Block) -> PseudoCoroutine {
		return	PseudoCoroutine(Continuation(block))
	}
	static func spawn(block: PseudoCoroutine->()) -> PseudoCoroutine {
		return	PseudoCoroutine(Continuation({ co in block(co); return nil }))
	}

	enum ExecutionState {
		case Ready
		case Waiting
		case Running
		case Done
	}
	convenience init(_ step: Continuation) {
		self.init([step])
	}
	init(_ steps: [Continuation]) {
		_continuations	=	steps
		_exestate	=	.Ready
	}

	var state: ExecutionState {
		get {
			return	_exestate
		}
	}

	func run() {
		assert(_exestate != .Running)
		assert(_exestate != .Done)

		_exestate	=	.Running
		_step()
	}
	func wait() {
		assert(_exestate == .Running)

		_exestate	=	.Waiting
	}

	///

	///	Provides continuation externally.
	func continuate(block: Block) -> PseudoCoroutine {
		_continuations.append(Continuation(block))
		return	self
	}
	func continuate(block: PseudoCoroutine->()) -> PseudoCoroutine {
		return	continuate { (co: PseudoCoroutine) -> Continuation in
			block(co)
			return	nil
		}
	}

	///

	private var	_continuations	=	[Continuation]()
	private var	_exestate	:	ExecutionState

	private func _step() {
		assert(_exestate == .Running)

		var keepRunning		=	false
		while keepRunning {
			assert(_exestate == .Running)

			if let continuation = _continuations.first {
				switch continuation {
				case .None:
					keepRunning	=	_continuations.count > 0
					_exestate	=	keepRunning ? .Running : .Done

				case .Continue(let continuation):
					let	c1	=	continuation(self)
					_continuations.insert(c1, atIndex: 0)
					keepRunning	=	_exestate == .Running
				}
			}
		}
	}
}




private func test1() {
	PseudoCoroutine.spawn { co in
		co.wait()

	}.continuate { (co: PseudoCoroutine) -> Continuation in
		return	nil

	}.continuate { (co: PseudoCoroutine) -> () in


	}.continuate { (co: PseudoCoroutine) -> Continuation in
		return	nil

	}
}








































