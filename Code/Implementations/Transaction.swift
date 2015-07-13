//
//  Transaction.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/01.
//  Copyright © 2015 Eonil. All rights reserved.
//

//public protocol StateSignalType {
//	typealias	Snapshot
//	typealias	Transaction	:	TransactionType
//	var		timing		:	StateSignalingTiming				{ get set }
//	var		state		:	Snapshot					{ get set }
//	var		by		:	StateSignalingCause<Snapshot,Transaction>	{ get set }
//}

public struct ValueTransaction<T>: TransactionType {
	public typealias	State		=	T
	public typealias	Mutation	=	(past: T, future: T)
	public var		mutations	:	[Mutation]
	public init(_ mutations: [Mutation]) {
		self.mutations	=	mutations
	}
}

public struct CollectionTransaction<K, V>: CollectionTransactionType, TransactionType {
	public typealias	Segment		=	K
	public typealias	State		=	V

	///	Defines single (conceptually) atomic segment mutation.
	///
	///	:param:		segment			
	///			Designates segment to be mutated.
	///
	///	:param:		past
	///			State of the segment before mutation.
	///
	///	:param:		future
	///			State of the segment after mutation.
	///
	public typealias	Mutation	=	(segment: K, past: V?, future: V?)
	public var 		mutations	:	[Mutation]
	public init(_ mutations: [Mutation]) {
		self.mutations	=	mutations
	}
}
//public extension CollectionTransaction where K: CollectionType, K: ArrayLiteralConvertible, V: CollectionType, V: ArrayLiteralConvertible {
//	public init(_ mutations: [(identity: K.Element, past: V.Element?, future: V.Element?)]) {
//		for m in mutations {
//			let	id	=	[m.identity] as K
//			let	past	=	[
//			[m.identity] as K
//			m.identity
//		}
//		let	ms1	=	mutations.map({ (K(arrayLiteral: $0), [$1], [$2]) }) as [Mutation]
//		self		=	CollectionTransaction(ms1)
//	}
//}
