////
////  TreePath.swift
////  SG2
////
////  Created by Hoon H. on 2015/06/20.
////  Copyright © 2015 Eonil. All rights reserved.
////
//
//
//
//public struct TreePath<T: Hashable>: Hashable {
//	public var	segments	=	[T]()		//	Empty array for root.
//	
//	public var hashValue: Int {
//		get {
//			return	segments.last?.hashValue ?? 0
//		}
//	}
//	
//	public func cutFirst() -> (first: TreePath<T>, rest: TreePath<T>) {
//		precondition(segments.count > 0)
//		let	first	=	TreePath(segments: [segments[0]])
//		let	rest	=	TreePath(segments: Array(segments[1..<segments.count]))
//		return	(first, rest)
//	}
//	public func cutLast() -> (last: TreePath<T>, rest: TreePath<T>) {
//		precondition(segments.count > 0)
//		let	last	=	TreePath(segments: [segments.last!])
//		let	rest	=	TreePath(segments: Array(segments[0..<segments.count-1]))
//		return	(last, rest)
//	}
//	public func appendSegment(segment: T) -> TreePath {
//		return	TreePath(segments: segments + [segment])
//	}
//	public func prependSegment(segment: T) -> TreePath {
//		return	TreePath(segments: [segment] + segments)
//	}
//}
//public func == <T: Hashable> (a: TreePath<T>, b: TreePath<T>) -> Bool {
//	return	a.segments == b.segments
//}
//
//
//
////enum TreeSignal<Segment: Hashable, V> {
////	typealias	Snapshot	=	[(path: TreePath<Segment>, value: V)]
////	typealias	Transaction	=	CollectionTransaction<TreePath<Segment>,V>
////	case Snapshot
////	case Transition	(transaction	: Transaction)
////	case Termination(snapshot	: Snapshot)						//<	Passes snapshot of current (latest) state.
////}
