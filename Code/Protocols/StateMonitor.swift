//
//  StateMonitor.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/01.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

///	Monitors session initiation and termination.
public protocol SessionMonitorType {
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
///	Then it may degrade performance greatly. Use carefully.
///
public protocol StateSegmentMonitorType: SensitiveStationType {
	typealias	Segment
	var		didAdd		:	(Segment->())?		{ get set }
	var		willRemove	:	(Segment->())?		{ get set }
}

public protocol StateCollectionSegmentMonitorType: StateSegmentMonitorType {
	typealias	Key
	typealias	Value
	typealias	Segment		=	(Key,Value)
}








public protocol ValueMonitorType: StateSegmentMonitorType, StateMonitorType, TransactionMonitorType, SessionMonitorType {
}

public protocol CollectionMonitorType: StateSegmentMonitorType, StateMonitorType, TransactionMonitorType, SessionMonitorType {
}




