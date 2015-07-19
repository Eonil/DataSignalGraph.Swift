//
//  StateTransformation.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/01.
//  Copyright © 2015 Eonil. All rights reserved.
//










public protocol SetFilteringSetChannelType: SetChannelType, RelayingStationType {
	typealias	IncomingSignal	=	TimingSignal<Set<Element>,CollectionTransaction<Element,()>>
	var filter: (Element->Bool)? { get set }
}
public protocol DictionaryFilteringDictionaryChannelType: DictionaryChannelType, RelayingStationType {
	typealias	IncomingSignal	=	TimingSignal<[Key:Value],CollectionTransaction<Key,Value>>
	var filter: ((Key,Value)->Bool)? { get set }
}
///	"sorting" means re-ordering of existing fixed data set.
///	"ordering" means defining order between elements for a mutating data set.
public protocol DictionaryOrderingArrayChannelType: ArrayChannelType, RelayingStationType {
	typealias	Key		:	Hashable
	typealias	Value
	typealias	Order		:	Comparable
	typealias	Element		=	(Key,Value)
	typealias	IncomingSignal	=	TimingSignal<[Key:Value],CollectionTransaction<Key,Value>>
	var order: ((Key,Value)->Order)? { get set }
}
public protocol ArrayMappingArrayChannelType: ArrayChannelType, RelayingStationType {
	typealias	IncomingElement
	typealias	OutgoingElement
	typealias	Element		=	OutgoingElement
	typealias	IncomingSignal	=	TimingSignal<[IncomingElement],CollectionTransaction<Int,IncomingElement>>
	var map: (IncomingElement->OutgoingElement)? { get set }
}







