////
////  TreeStorage.swift
////  ADHOC_SignalGraph3
////
////  Created by Hoon H. on 2015/06/26.
////  Copyright (c) 2015 Eonil. All rights reserved.
////
//
//import Foundation
//
//class ArrayTreeStorage<V> {
//	typealias	Path	=	TreePath<Int>
//	typealias	Node	=	ArrayTreeNode<V>
//	
//	init(_ snapshot: [Path:V]) {
//		_snapshot	=	snapshot
//	}
//	
//	var root: Node? {
//		get {
//			return	_root
//		}
//		set(v) {
//			_root	=	v
//		}
//	}
//	
//	///
//	
//	private var	_snapshot	=	Dictionary<Path,V>()
//	private var	_root		:	Node?
//}
//
/////	A mutation interface to `TreeStorage`.
/////	This is provided to provide reference-able identity for each nodes.
/////
//class ArrayTreeNode<V> {
//	typealias	Path	=	TreePath<Int>
//	
//	init(_ state: V) {
//		value		=	StateStorage(state)
//	}
//	
//	let	value		:	StateStorage<V>
//	let	subnodes	=	ArrayStorage<ArrayTreeNode<V>>([])
//	
//	///
//	
//	private var	_storageID		:	ObjectIdentifier?
//	private var	_parentID		:	ObjectIdentifier?
//}
//
//
//
//
//
