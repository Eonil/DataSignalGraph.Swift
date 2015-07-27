//
//  ArrayFilteringArrayChannel.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/07/25.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

///	Intercepts array storage signal
///
public class ArrayFilteringArrayChannel<T>: ArrayFilteringArrayChannelType {

	typealias	Element			=	T
	typealias	Transaction		=	CollectionTransaction<Range<Int>,[T]>
	typealias	IncomingSignal		=	TimingSignal<[T],CollectionTransaction<Range<Int>,[T]>>
	typealias	OutgoingSignal		=	TimingSignal<[T],CollectionTransaction<Range<Int>,[T]>>

	public init() {
	}

	public var snapshot: [T] {
		get {
			return	_onlineSession!.filteredArray
		}
	}
	public var filter: ((Int,T)->Bool)? {
		willSet {
			assert(_onlineSession == nil, "You cannot replace `filter` while this channel is connected to a source storage.")
		}
	}

	public func cast(signal: IncomingSignal) {
		_cast(signal)
	}

	public func register(identifier: ObjectIdentifier, handler: OutgoingSignal -> ()) {
		if _isOnline() {
			handler(HOTFIX_TimingSignalUtility.didBeginStateBySession(_onlineSession!.filteredArray))
		}
		_relay.register(identifier, handler: handler)
	}
	public func deregister(identifier: ObjectIdentifier) {
		let	handler	=	_relay.handlerForIdentifier(identifier)
		_relay.deregister(identifier)
		if _isOnline() {
			handler(HOTFIX_TimingSignalUtility.willEndStateBySession(_onlineSession!.filteredArray))
		}
	}
	public func register<S : SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		if _isOnline() {
			s.cast(HOTFIX_TimingSignalUtility.didBeginStateBySession(_onlineSession!.filteredArray))
		}
		_relay.register(s)
	}
	public func deregister<S : SensitiveStationType where S.IncomingSignal == OutgoingSignal>(s: S) {
		_relay.deregister(s)
		if _isOnline() {
			s.cast(HOTFIX_TimingSignalUtility.willEndStateBySession(_onlineSession!.filteredArray))
		}
	}
	

	///

	private var	_relay			=	Relay<OutgoingSignal>()
	private var	_onlineSession		:	_OnlineSession<T>?

	private func _cast(signal: IncomingSignal) {
		switch signal {
		case .DidBegin(let subsignal):
			switch subsignal() {
			case .Session(let s):
				_startSessionWithSnapshot(s())
			case .Transaction(let t):
				_applyTransactionWithFiltering(t())
			case .Mutation(let m):
				break
			}
		case .WillEnd(let subsignal):
			switch subsignal() {
			case .Session(let s):
				_finishSessionWithSnapshot(s())
			case .Transaction(let t):
				break
			case .Mutation(let m):
				break
			}
		}
	}
	private func _isOnline() -> Bool {
		return	_onlineSession != nil
	}
	private func _startSessionWithSnapshot(snapshot: [T]) {
		assert(filter != nil, "You must set a `filter` before connecting this object to a source.")
		assert(_isOnline() == false)
		_onlineSession	=	_OnlineSession(filter!)
		_relay.cast(HOTFIX_TimingSignalUtility.didBeginStateBySession(_onlineSession!.filteredArray))
	}
	private func _finishSessionWithSnapshot(snapshot: [T]) {
		assert(_isOnline() == true)
		_relay.cast(HOTFIX_TimingSignalUtility.willEndStateBySession(_onlineSession!.filteredArray))
		_onlineSession	=	nil
	}

	private func _applyTransactionWithFiltering(t: IncomingSignal.Transaction) {
//		assert(_onlineSession != nil)
//		for m in t.mutations {
//			switch m {
//			case (_, nil, _):
//				var	i1	=	0
//				for i in m.segment {
//					_onlineSession!.insertUnfilteredElement(m.future![i1], at: i)
//					i1++
//				}
//			case (_, _, _):
//				var	i1	=	0
//				for i in m.segment {
//					_onlineSession!.deleteUnfilteredElement(m.future![i1], at: i)
//					_onlineSession!.insertUnfilteredElement(m.future![i1], at: i)
//					i1++
//				}
//			case (_, _, nil):
//				var	i1	=	0
//				for i in m.segment {
//					_onlineSession!.deleteUnfilteredElement(m.future![i1], at: i)
//					i1++
//				}
//			}
//		}
	}
}





///	All each array element must be processed one by one 
///	because one element in a strip may be excluded.
///
private struct _OnlineSession<T> {

	typealias	Mutation	=	ArrayStorage<T>.Signal.Transaction.Mutation
	typealias	SingleMutation	=	(segment: Int, past: T?, future: T?)

	let		shouldIncludeElement	:	(Int,T)->Bool

	var		filteredArray		=	[T]()
	var		excludedIndexes		=	NSMutableIndexSet()

	init(_ shouldIncludeElement: (Int,T)->Bool) {
		self.shouldIncludeElement	=	shouldIncludeElement
	}

	mutating func applyTransactionWithFiltering(t: ArrayStorage<T>.Signal.Transaction, relay: Relay<ArrayStorage<T>.Signal>) {
		var	ms1	=	[Mutation]()
		var	mfs	=	[PrefilteredMutation]()
		for m in t.mutations {
			let	mf	=	filterMutation(m)
			mfs.append(mf.0)
			if let mf1 = mf.1 {
				mfs.append(mf1)
			}
		}
		for mf in mfs {
			///	Values for these indexes are excluded,
			///	so we need to store these indexes.
			if let idxs = mf.excludedSegments.future {
				idxs.map(excludedIndexes.addIndex)
			}
			let	startingIndex		=	mf.mutation.segment.startIndex
			let	filteredIndex		=	mapFilteredIndexFromUnfilteredIndex(startingIndex)
			let	filteredRange		=	filteredIndex..<(filteredIndex + count(mf.mutation.segment))
			let	filteredMutation	=	Mutation(filteredRange, mf.mutation.past, mf.mutation.future)
			ms1.append(filteredMutation)

			///	Values for these indexes has been removed from source storage.
			///	So we should stop storing them.
			if let idxs = mf.excludedSegments.past {
				idxs.map(excludedIndexes.removeIndex)
			}
//			relay.cast(HOTFIX_TimingSignalUtility.willEndStateByMutation(filteredArray, mutation: filteredMutation))
//
//			switch filteredMutation {
//			case (_,nil,_):
//				filteredArray.splice(filteredMutation.future!, atIndex: filteredMutation.segment.startIndex)
//			case (_,_,_):
//				filteredArray.replaceRange(filteredMutation.segment, with: filteredMutation.future!)
//			case (_,_,nil):
//				filteredArray.removeRange(filteredMutation.segment)
//			}
//			relay.cast(HOTFIX_TimingSignalUtility.didBeginStateByMutation(filteredArray, mutation: filteredMutation))
		}

		let	t1	=	ArrayStorage<T>.Signal.Transaction(ms1)
		StateStorageUtility.apply(t1, to: &filteredArray, relay: relay)
	}

//	mutating func applySingleMutation(unfilteredSingleMutation m: SingleMutation) -> [SingleMutation] {
//		switch unfilteredSingleMutation {
//		case (_,nil,_):
//			return	(mapFilteredIndexFromUnfilteredIndex(unfilteredSingleMutation.segment), nil, unfilteredSingleMutation.future)
//		case (_,_,_):
//			return	(mapFilteredIndexFromUnfilteredIndex(unfilteredSingleMutation.segment), nil, unfilteredSingleMutation.future)
//		case (_,_,nil):
//			return	(mapFilteredIndexFromUnfilteredIndex(unfilteredSingleMutation.segment), nil, unfilteredSingleMutation.future)
//		}
//		return	(unfilteredSingleMutation)
//	}
//
//	func decomposeMutation(m: Mutation) -> [SingleMutation] {
//		var	mas1	=	[SingleMutation]()
//		switch m {
//		case (_,nil,_):
//			fallthrough
//		case (_,_,_):
//			for i in 0..<count(m.segment) {
//				let	idx	=	m.segment.startIndex + i
//				let	past	=	m.past?[i]
//				let	future	=	m.future?[i]
//				let	ma1	=	SingleMutation(idx, past, future)
//				mas1.append(ma1)
//			}
//		case (_,_,nil):
//			for i in reverse(0..<count(m.segment)) {
//				let	idx	=	m.segment.startIndex + i
//				let	past	=	m.past?[i]
//				let	future	=	m.future?[i]
//				let	ma1	=	SingleMutation(idx, past, future)
//				mas1.append(ma1)
//			}
//		}
//		return	mas1
//	}
//	///	Multiple mutation can be composed if there's any inconsecutive atoms.
//	func recomposeMutations(singleMutations: [SingleMutation]) -> [Mutation] {
//		if singleMutations.count == 0 {
//			return	[]
//		}
////		var	last	=	atoms.first!.segment
////		for a in atoms {
////			let	cur	=	a.segment
////			let	delta	=	max(cur,last) - min(cur,last)
////			assert(delta != 0)
////			if delta == 1 {
////
////			} else {
////
////			}
////		}
//		func makeMutipleMutation(a: SingleMutation) -> Mutation {
//			let	segment	=	a.segment...a.segment
//			let	past	=	a.past == nil ? nil : [a.past!] as [T]?
//			let	future	=	a.future == nil ? nil : [a.future!] as [T]?
//			return	(segment, past, future)
//		}
//		return	singleMutations.map(makeMutipleMutation)
//	}

//	mutating func applyTransactionWithFiltering(t: ArrayStorage<T>.Signal.Transaction, relay: Relay<ArrayStorage<T>.Signal>) {
//		for m in t.mutations {
//			let	ms1		=	filterMutation(m)
//			for m1 in ms1 {
//				assert(m1.past == nil || m1.future == nil || (m1.past!.count == m1.future!.count))
//				switch m1 {
//				case (_, nil, _):
//					let	exclusionCount	=	m1.segment.
//					let	exclusionRange	=	m1.
//
//				case (_, _, _):
//
//				case (_, _, nil):
//
//				}
//			}
//		}
//		let	ms1	=	t.mutations.map({self.filterMutation($0)}).reduce([], combine: +)
//		ms1
//
//
////		var	ms1	=	Array<ArrayStorage<T>.Signal.Transaction.Mutation>()
////		for m in t.mutations {
////			switch m {
////			case (_, nil, _):
////				var	i1	=	0
////				for i in m.segment {
////					if let m1 = insertUnfilteredElement(m.future![i1], at: i, relay: relay) {
////						ms1.append(m1)
////					}
////					i1++
////				}
////			case (_, _, _):
////				var	i1	=	0
////				for i in m.segment {
////					if let m1 = updateUnfilteredElement(m.past![i1], at: i, with: m.future![i1], relay: relay) {
////						ms1.append(m1)
////					}
////					i1++
////				}
////			case (_, _, nil):
////				var	i1	=	0
////				for i in m.segment {
////					if let m1 = deleteUnfilteredElement(m.past![i1], at: i, relay: relay) {
////						ms1.append(m1)
////					}
////					i1++
////				}
////			}
////		}
//	}

	///	A mutation that excluded all index/value pairs using specified filter function.
	///	Segment range reduced, but starting index remains as original, so you can calculate
	///	proper index numbers by conjunction with `excludedSegments`.
	///
	typealias	PrefilteredMutation	=	(mutation: Mutation, excludedSegments: (past: [Int]?, future: [Int]?))
	typealias	MaybeDouble		=	(PrefilteredMutation, PrefilteredMutation?)
//
	func filterMutation(m: Mutation) -> MaybeDouble {
		assert(m.past == nil || count(m.segment) == m.past!.count)
		assert(m.future == nil || count(m.segment) == m.future!.count)

		func filterElements(range: Range<Int>, values: [T]) -> (Range<Int>, [T], excludedSegment: [Int]) {
			assert(count(range) == values.count)
			var	values1		=	[T]()
			var	exclusion	=	[Int]()
			for i in 0..<count(range) {
				let	idx	=	range.startIndex + i
				let	val	=	values[i]
				let	inc	=	shouldIncludeElement(idx,val)
				if inc {
					values1.append(val)
				}
				else {
					exclusion.append(idx)
				}
			}
			return	(range.startIndex..<(range.startIndex + values1.count), values1, exclusion)
		}

		switch m {
		case (_, nil, _):
			let	es1	=	filterElements(m.segment, m.future!)
			let	mf	=	PrefilteredMutation((es1.0, nil, es1.1), (nil, es1.excludedSegment))
			return	(mf, nil)

		case (_, _, _):
			let	es1	=	filterElements(m.segment, m.past!)
			let	es2	=	filterElements(m.segment, m.future!)
			let	mf1	=	PrefilteredMutation((es1.0, es1.1, nil), (es1.excludedSegment, nil))
			let	mf2	=	PrefilteredMutation((es2.0, nil, es2.1), (nil, es2.excludedSegment))
			return	(mf1, mf2)
//			if es1.0 == es2.0 {
//				let	mf	=	PrefilteredMutation((es1.0, es1.1, es2.1), (es1.excludedSegment, es2.excludedSegment))
//				return	(mf, nil)
//			}
//			else {
//				let	mf1	=	PrefilteredMutation((es1.0, es1.1, nil), (es1.excludedSegment, nil))
//				let	mf2	=	PrefilteredMutation((es2.0, nil, es2.1), (nil, es2.excludedSegment))
//				return	(mf1, mf2)
//			}

		case (_, _, nil):
			let	es1	=	filterElements(m.segment, m.past!)
			let	mf	=	PrefilteredMutation((es1.0, es1.1, nil), (es1.excludedSegment, nil))
			return	(mf, nil)

		}
//
//		var	idx	=	m.segment.startIndex
//		for idx in m.segment {
//
//		}
//
//		var	ms1		=	[Mutation]()
//		var	c		=	0
//		for idx in m.segment {
//			let	idx1	=	mapFilteredIndexFromUnfilteredIndex(idx)
//			let	past	=	m.past?[c]
//			let	future	=	m.future?[c]
//			let	m1	=	Mutation(idx1...idx1, past == nil ? nil : [past!], future == nil ? nil : [future!])
//			ms1.append(m1)
//			c++
//		}
//		return	ms1
	}
//
////	mutating func insertUnfilteredElement(element: T, at index: Int, relay: Relay<ArrayStorage<T>.Signal>) -> Mutation? {
////		if shouldIncludeElement(index, element) == true {
////			let	filteredIndex		=	mapFilteredIndexFromUnfilteredIndex(index)
////			let	filteredMutation	=	Mutation(index...index, nil, [element])
////			relay.cast(HOTFIX_TimingSignalUtility.willEndStateByMutation(filteredArray, mutation: filteredMutation))
////			filteredArray.insert(element, atIndex: index)
////			relay.cast(HOTFIX_TimingSignalUtility.didBeginStateByMutation(filteredArray, mutation: filteredMutation))
////			return	filteredMutation
////		}
////		else {
////			assert(excludedIndexes.containsIndex(index) == false)
////			excludedIndexes.addIndex(index)
////			return	nil
////		}
////	}
////	mutating func updateUnfilteredElement(element: T, at index: Int, with newElement: T, relay: Relay<ArrayStorage<T>.Signal>) -> Mutation? {
////		if shouldIncludeElement(index, element) == true {
////			let	filteredIndex		=	mapFilteredIndexFromUnfilteredIndex(index)
////			let	filteredMutation	=	Mutation(index...index, [element], [newElement])
////			relay.cast(HOTFIX_TimingSignalUtility.willEndStateByMutation(filteredArray, mutation: filteredMutation))
////			filteredArray[index]		=	newElement
////			relay.cast(HOTFIX_TimingSignalUtility.didBeginStateByMutation(filteredArray, mutation: filteredMutation))
////			return	filteredMutation
////		}
////		else {
////			assert(excludedIndexes.containsIndex(index) == true)
////			return	nil
////		}
////	}
////	mutating func deleteUnfilteredElement(element: T, at index: Int, relay: Relay<ArrayStorage<T>.Signal>) -> Mutation? {
////		if shouldIncludeElement(index, element) == true {
////			let	filteredIndex		=	mapFilteredIndexFromUnfilteredIndex(index)
////			let	filteredMutation	=	Mutation(index...index, [element], nil)
////			relay.cast(HOTFIX_TimingSignalUtility.willEndStateByMutation(filteredArray, mutation: filteredMutation))
////			filteredArray.removeAtIndex(index)
////			relay.cast(HOTFIX_TimingSignalUtility.didBeginStateByMutation(filteredArray, mutation: filteredMutation))
////			return	filteredMutation
////		}
////		else {
////			assert(excludedIndexes.containsIndex(index) == true)
////			excludedIndexes.removeIndex(index)
////			return	nil
////		}
////	}




//	func insertPrefilteredMutation(entry: (Int,T)) -> (

	func mapFilteredIndexFromUnfilteredIndex(index: Int) -> Int {
		assert(excludedIndexes.containsIndex(index) == false, "You cannot map an index that is already excluded.")
		return	index - countIndexesLessThenIndex(index)
	}
	///	O(N) where N is number of excluded indexes that are less than specified `index`.
	func countIndexesLessThenIndex(index: Int) -> Int {
		var	count	=	0
		for idx in excludedIndexes {
			if idx < index {
				count--
			}
			else {
				break
			}
		}
		return	count
	}
}

