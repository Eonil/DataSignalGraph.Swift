//
//  ArrayMonitor.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/02.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

public class ArrayMonitor<T>: StateSegmentMonitorType {
	public typealias	Key		=	Range<Int>
	public typealias	Value		=	[T]
	public typealias	Segmnet		=	(Range<Int>,[T])
	public typealias	Signal		=	StateSignal<[T], CollectionTransaction<Range<Int>,[T]>>

	public var		didAdd		:	((Range<Int>, [T])->())?
	public var		willRemove	:	((Range<Int>, [T])->())?

	public func cast(signal: Signal) {
		
	}
	
}