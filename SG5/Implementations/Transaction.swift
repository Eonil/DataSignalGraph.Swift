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

public struct ValueTransaction<K, V>: TransactionType {
	public typealias	State		=	V
	public typealias	Mutation	=	(past: V, future: V)
	public var		mutations	:	[Mutation]
}

public struct CollectionTransaction<K, V>: CollectionTransactionType, TransactionType {
	public typealias	Identity	=	K
	public typealias	State		=	V
	public typealias	Mutation	=	(identity: K, past: V?, future: V?)
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
