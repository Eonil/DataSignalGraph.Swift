//
//  CollectionExtensions.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/26.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

extension Set {
	mutating func apply(transaction: CollectionTransaction<T,()>) {
		for m in transaction.mutations {
			switch (m.past, m.future) {
			case (nil, nil):
				fatalError("Illegal signal mutation combination.")
			case (nil, _):
				insert(m.identity)
			case (_, nil):
				remove(m.identity)
			case (_, _):
				fatalError("Illegal signal mutation combination for set transaction.")
			}
		}
	}
}
extension Array {
	mutating func apply(transaction: CollectionTransaction<Int,T>) {
		for m in transaction.mutations {
			switch (m.past, m.future) {
			case (nil, nil):
				fatalError("Illegal signal mutation combination.")
			case (nil, _):
				assert(m.identity <= count)
				insert(m.future!, atIndex: m.identity)
			case (_, nil):
				assert(m.identity < count)
				removeAtIndex(m.identity)
			case (_, _):
				assert(m.identity < count)
				self[m.identity]	=	m.future!
			}
		}
	}
}
extension Dictionary {
	mutating func apply(transaction: CollectionTransaction<Key,Value>) {
		for m in transaction.mutations {
			switch (m.past, m.future) {
			case (nil, nil):
				fatalError("Illegal signal mutation combination.")
			case (nil, _):
				self[m.identity]	=	m.future!
			case (_, nil):
				assert(self[m.identity] != nil)
				removeValueForKey(m.identity)
			case (_, _):
				assert(self[m.identity] != nil)
				self[m.identity]	=	m.future!
			}
		}
	}
}











