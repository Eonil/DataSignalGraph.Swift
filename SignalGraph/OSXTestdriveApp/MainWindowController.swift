//
//  MainWindowController.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/05/20.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit

class MainWindowController {
	
	let	window	=	NSWindow()
	
	let	scroll	=	NSScrollView()
	let	list	=	ListViewController()
	
	init() {
		window.styleMask	|=	NSResizableWindowMask
							|	NSClosableWindowMask
		window.setFrame(CGRect(x: 100, y: 100, width: 400, height: 300), display: true)
		window.makeKeyAndOrderFront(self)
		
		scroll.documentView	=	list.tableView
		window.contentView	=	scroll
	}
}