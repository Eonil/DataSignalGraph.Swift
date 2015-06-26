//
//  CollectionTransaction.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/26.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public struct CollectionTransaction<K,V> {
	public typealias	Mutation	=	(identity: K, past: V?, future: V?)
	public var 		mutations	:	[Mutation]
}



public protocol CollectionTransactionApplicable {
	typealias	MutationKey
	typealias	MutationValue
	func apply(transaction: CollectionTransaction<MutationKey,MutationValue>)
}