////
////  OrderingTreeSignal.swift
////  SignalGraph
////
////  Created by Hoon H. on 2015/05/05.
////  Copyright (c) 2015 Eonil. All rights reserved.
////
//
//import Foundation
//
//enum TreeSignal<K: Hashable, Tree, Node> {
//	typealias	Snapshot	=	Tree
//	typealias	Transaction	=	CollectionTransaction<TreeNodeLocation<K>,Node>
//	case Initiation	(snapshot	: 	Snapshot)
//	case Transition	(transaction	:	Transaction)
//	case Termination(snapshot	: 	Snapshot)
//}
//
//extension TreeSignal: CollectionSignalType {
//	var initiation: Snapshot? {
//		get {
//			switch self {
//			case .Initiation(snapshot: let s):		return	s
//			default:								return	nil
//			}
//		}
//	}
//	var transition: Transaction? {
//		get {
//			switch self {
//			case .Transition(transaction: let s):	return	s
//			default:								return	nil
//			}
//		}
//	}
//	var termination: Snapshot? {
//		get {
//			switch self {
//			case .Termination(snapshot: let s):		return	s
//			default:								return	nil
//			}
//		}
//	}
//}
//
//
//
/////	Represents location of a tree node.
/////
/////	If `indexes == []`, it's a root node.
////	Otherwise, this designates a node at the index at the level.
//struct TreeNodeLocation<K: Hashable>: Hashable {
//	var	indexes: [K]
//	
//	var hashValue: Int {
//		get {
//			return	indexes.last?.hashValue ?? 0
//		}
//	}
//}
//func == <K: Hashable> (a: TreeNodeLocation<K>, b: TreeNodeLocation<K>) -> Bool {
//	return	a.indexes == b.indexes
//}
//
////struct PlaneTree<T> {
////	subscript(index: PlaneTreeNodeLocation) -> T {
////		get {
////			return	_root
////		}
////	}
////	
////	private var	_root	:	_Node<T>?
////}
////
////private struct _Node<T> {
////	
////}
//
//
//
