//
//  StateMonitor.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/01.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

///	Monitors session initiation and termination.
public protocol SessionMonitor {
	typealias	Snapshot
	var		didInitiate	:	(()->())?		{ get set }
	var		willTerminate	:	(()->())?		{ get set }
}

///	Monitors transaction application.
public protocol TransactionMonitorType {
	typealias	Transaction
	var		willApply	:	(Transaction->())?	{ get set }
	var		didApply	:	(Transaction->())?	{ get set }
}

///	Monitors state mutations.
public protocol StateMonitorType {
	typealias	Snapshot
	var		didBegin	:	(Snapshot->())?		{ get set }
	var		willEnd		:	(Snapshot->())?		{ get set }
}

///	Provides monitoring of add/remove of each segment. (element in collections)
///	
///	**NOTE** These events are occured for EVERY element so it's very frequent.
///	Then it may degrade performance greatly. Use with your care.
///
public protocol StateSegmentMonitorType: SensitiveStationType {
	typealias	Key
	typealias	Value
	typealias	Segment		=	(Key,Value)
	var		didAdd		:	(Segment->())?		{ get set }
	var		willRemove	:	(Segment->())?		{ get set }
}