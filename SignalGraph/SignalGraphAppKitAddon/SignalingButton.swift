//
//  SignalingButton.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/05/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit
import SignalGraph




public class SignalingButton: NSButton {
	public init() {
		agent.owner		=	self
		super.target	=	agent
		super.action	=	"onAction:"
	}
	
	public var emitter: SignalEmitter<()> {
		get {
			return	disp
		}
	}
	
	@availability(*,unavailable)
	public required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	@availability(*,unavailable)
	public override weak var target: AnyObject? {
		willSet {
			fatalError()
		}
	}
	@availability(*,unavailable)
	public override var action: Selector {
		willSet {
			fatalError()
		}
	}
	
	@availability(*,unavailable)
	public override func sendAction(theAction: Selector, to theTarget: AnyObject?) -> Bool {
		fatalError()
	}
	@availability(*,unavailable)
	public override func sendActionOn(mask: Int) -> Int {
		fatalError()
	}
	
	////
	
	private let	agent	=	Agent()
	private let	disp	=	SignalDispatcher<()>()
	
	private func onAction() {
		disp.signal()
	}
	
	@objc
	private final class Agent: NSObject {
		weak var owner: SignalingButton?
		@objc
		func onAction(AnyObject?) {
			owner!.onAction()
		}
	}
}






