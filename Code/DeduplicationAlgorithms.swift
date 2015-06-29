//
//  DeduplicationAlgorithms.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

func deduplicate<T>() {




}



struct ArrayIndexDeduplicator {


	enum State {
		case Inserted
		case Updated
		case Deleted
	}

	var	slots	=	[Int: State]()
	var

	func markInsert(atIndex: Int) {
		if slots[atIndex] == .Deleted {
			slots[atIndex]	=	nil
		} else {
			slots[atIndex]	=	.Inserted
		}
	}
	func markUpdate(atIndex: Int) {
		slots[atIndex]	=	.Updated
	}
	func markDelete(atIndex: Int) {
		if slots[atIndex] == .Inserted {
			slots[atIndex]	=	nil
		} else {
			slots[atIndex]	=	.Deleted
		}
	}

	func produce() -> [(Int,State)] {
		sorted(slots.keys)
		for (idx,st) in slots {

		}
	}
}

struct SparseArray<T> {
	func insert(value: T, index: Int) {

	}
	func delete(index:Int) {
		
	}
	var State {
		var	singleValue	:	T?
		var	emptySlotCount	:	Int?
	}
	private var	_blocks		=	[State]()
}













