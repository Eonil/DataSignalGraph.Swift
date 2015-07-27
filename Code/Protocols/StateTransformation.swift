//
//  StateTransformation.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/01.
//  Copyright © 2015 Eonil. All rights reserved.
//











///	You can register/deregister observers while this channel is not connected to a
///	source, but session will not start until this to be connected to a source.
///
public protocol SetFilteringSetChannelType: SetChannelType, RelayingStationType {
	typealias	IncomingSignal	=	TimingSignal<Set<Element>,CollectionTransaction<Element,()>>
	var filter: (Element->Bool)? { get set }
}

///	You can register/deregister observers while this channel is not connected to a
///	source, but session will not start until this to be connected to a source.
///
public protocol DictionaryFilteringDictionaryChannelType: DictionaryChannelType, RelayingStationType {
	typealias	IncomingSignal	=	TimingSignal<[Key:Value],CollectionTransaction<Key,Value>>
	var filter: ((Key,Value)->Bool)? { get set }
}

///	"sorting" means re-ordering of existing fixed data set.
///	"ordering" means defining order between elements for a mutating data set.
///
///	You can register/deregister observers while this channel is not connected to a
///	source, but session will not start until this to be connected to a source.
///
public protocol DictionaryOrderingArrayChannelType: ArrayChannelType, RelayingStationType {
	typealias	Key		:	Hashable
	typealias	Value
	typealias	Order		:	Comparable
	typealias	Element		=	(Key,Value)
	typealias	IncomingSignal	=	TimingSignal<[Key:Value],CollectionTransaction<Key,Value>>
	var order: ((Key,Value)->Order)? { get set }
}

///	You can register/deregister observers while this channel is not connected to a
///	source, but session will not start until this to be connected to a source.
///
public protocol ArrayMappingArrayChannelType: ArrayChannelType, RelayingStationType {
	typealias	IncomingElement
	typealias	OutgoingElement
	typealias	Element		=	OutgoingElement
	typealias	IncomingSignal	=	TimingSignal<[IncomingElement],CollectionTransaction<Int,IncomingElement>>
	var map: (IncomingElement->OutgoingElement)? { get set }
}

///	You can register/deregister observers while this channel is not connected to a
///	source, but session will not start until this to be connected to a source.
///
public protocol ArrayFilteringArrayChannelType: ArrayChannelType, RelayingStationType {
	typealias	IncomingSignal	=	TimingSignal<[Element],CollectionTransaction<Int,Element>>
	var filter: ((Int,Element)->Bool)? { get set }
}







