//
//  StateTransaction.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/01.
//  Copyright © 2015 Eonil. All rights reserved.
//

public protocol ValueTransactionType: TransactionType {
}
public protocol CollectionTransactionType: TransactionType {
	typealias	Segment
	typealias	State
	typealias	Mutation	=	(segment: Segment, past: State?, future: State?)
	var mutations: [Mutation] { get }
}

