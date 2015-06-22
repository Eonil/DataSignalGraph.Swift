////
////  ArrayTree.swift
////  SG2
////
////  Created by Hoon H. on 2015/06/20.
////  Copyright © 2015 Eonil. All rights reserved.
////
//
//import Foundation
//
//
//
//
//
//
//
//
//
//
//
//
//public class ArrayTreeStorage<T>: StorageType {
//	public typealias	Segment		=	Int
//	public typealias	State		=	[TreePath<Segment>: T]
//	public typealias	Signal		=	CollectionSignal<[TreePath<Segment>: T], TreePath<Segment>, T>
//	
//	public init(snapshot: State) {
//		_rebuildTree(snapshot)
//	}
//	
//	///	This is very expensive operation because this objext does not keep
//	///	tree-node data in this form, and calling this property will trigger
//	///	full tree iteration with full conversion. Use only when you absolutely 
//	///	need this.
//	///
//	///	`O(N * M)` where `N` is number of nodes and `M` is average depth of nodes.
//	///
//	public var snapshot: State {
//		get {
//			return	_snapshot()
//		}
//		set(v) {
//			_rebuildTree(v)
//		}
//	}
//	public var root: ArrayTreeNode<T>? {
//		get {
//			return	_root
//		}
//		set(v) {
//			_root?._disconnect()
//			_root?._host	=	nil
//			_root		=	v
//			_root?._host	=	self
//			_root?._connect()
//		}
//	}
//	
//	///
//	
//	private typealias _Pair		=	(path: TreePath<Segment>, value: T)
//	
////	private let	_dispatcher	=	StateDispatcher<TreeStorage<Node, Segment, Value>>()
//	private let	_dispatcher	=	StateDispatcher<DictionaryStorage<TreePath<Int>, T>>()
//	private var	_root		:	ArrayTreeNode<T>?
//	
//	private func _snapshot() -> State {
//		if _root == nil {
//			return	[:]
//		}
//		var	map	=	State()
//		_root!._collectStateSnapshot(&map)
//		return	map
//	}
//	private func _rebuildTree(snapshot: State) {
//		
//		fatalError("Not implemented yet...")
//	}
//	
//	private func _valuewillApply(signal: ValueSignal<T>, onNode node: ArrayTreeNode<T>) {
//		
//	}
//	private func _valueDidApply(signal: ValueSignal<T>, onNode node: ArrayTreeNode<T>) {
//		
//	}
//}
//
//public class ArrayTreeNode<T> {
//	public typealias	Segment		=	Int
//	public typealias	State		=	[TreePath<Segment>: T]
//	
//	public init(_ data: T) {
//		value	=	ValueStorage(data)
//	}
//	deinit {
//		assert(_connected == false)
//	}
//	
//	///
//	
//	public let	value		:	ValueStorage<T>
//	public let	subnodes	=	ArrayStorage<ArrayTreeNode<T>>([])
//	
//	///
//	
//	private let		_valuemon	=	ValueMonitor<T>()
//	private let		_subnodemon	=	ArrayMonitor<ArrayTreeNode<T>>()
//	private weak var	_host		:	ArrayTreeStorage<T>?
//	private weak var	_supernode	:	ArrayTreeNode?
//	private var		_connected	=	false
//	
//	private func _connect() {
//		assert(_connected == false)
//		_valuemon.willApply	=	{ [weak self] in self!._host?._valuewillApply($0, onNode: self!) }
//		_valuemon.didApply	=	{ [weak self] in self!._host?._valueDidApply($0, onNode: self!) }
//		value.register(_valuemon)
//		subnodes.register(_subnodemon)
//		_connected	=	true
//	}
//	private func _disconnect() {
//		assert(_connected == true)
//		value.deregister(_valuemon)
//		subnodes.deregister(_subnodemon)
//		_connected	=	false
//	}
//	
//	private func _indexInSupernode() -> Int {
//		return	_supernode!.subnodes.indexOf({ $0 === self })!
//	}
//	private func _pathFromStorage() -> TreePath<Segment> {
//		let	index	=	_indexInSupernode()
//		let	path1	=	_supernode!._pathFromStorage()
//		let	path2	=	path1.appendSegment(index)
//		return	path2
//	}
//	private func _collectStateSnapshot(inout map: State) {
//		let	path	=	_pathFromStorage()
//		map[path]	=	value.snapshot
//		for subnode in subnodes {
//			subnode._collectStateSnapshot(&map)
//		}
//	}
//}
//
//
////private func _haltForDebugging() {
////	assert(false)
////}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//////protocol TreeNodeCollectionType: SignallableCollectionStorage {
//////}
////protocol TreeNodeType: class {
////	typealias	Data
////	typealias	Segment		:	Hashable
////	typealias	SubnodeStorage	:	SignallableCollectionType
////}
////class TreeStorage<Segment: Hashable, Value, Node: TreeNodeType> {
////
////	typealias	State		=	[TreePath<Segment>: Value]
////
////	init(snapshot: State) {
////
////	}
////
//////	private(set) var root: Node?
////	var root: Node? {
////		get {
////			fatalError()
//////			return	_root
////		}
////		set(v) {
//////			_root	=	v
////		}
////	}
////
////	///
////
//////	private var	_root	:	Node?
////}
////
////class TreeNode<Segment: Hashable, Value>: TreeNodeType {
////	init(_ data: Value) {
////		value	=	ValueStorage(data)
////	}
////
////	let	value	:	ValueStorage<Value>
////}
////
////class ArrayTreeNode<Value>: TreeNode<Int, Value> {
////	init(_ data: Value) {
////
////	}
////	let	subnodes	:	SubnodeStorage
////}