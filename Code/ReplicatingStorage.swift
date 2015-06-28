//
//  ReplicatingStorage.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/06/27.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

//class ReplicatingStorage: ChannelType, CollectionTransactionApplicable {
//	
//}

class DeferringSignalMonitor<T>: SignalMonitor<T> {

}

public class BufferingSetStorage<T: Hashable>: SignalMonitor<CollectionSignal<Set<T>,T,()>>, CollectionTransactionApplicable {
	public func apply(transaction: CollectionTransaction<T, ()>) {
		
	}

	public var run: Bool = false
}