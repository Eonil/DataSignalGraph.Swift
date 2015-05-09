//
//  Aliases.swift
//  DataSignalGraph
//
//  Created by Hoon H. on 2015/05/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

extension DictionaryStorage {
	typealias	Signal			=	DictionarySignal<K,V>
	typealias	Replication		=	DictionaryReplication<K,V>
	typealias	Editor			=	DictionaryEditor<K,V>
	typealias	Filtering		=	DictionaryFilteringDictionaryStorage<K,V>
	typealias	Sorting			=	DictionarySortingArrayStorage<K,V>
}