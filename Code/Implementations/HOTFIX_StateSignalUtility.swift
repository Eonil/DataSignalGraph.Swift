//
//  HOTFIX_TimingSignalUtility.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/01.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

///	Exists because Swift 1.x cannot support multi-type enum and that makes 
///	signal building overly complex more than it should be.
///
///	These functions will be removed with Swift 2.x and replaced by direct instantiation
///	of each enum values.
///
struct HOTFIX_TimingSignalUtility {
	static func didBeginStateBySession<S,T: TransactionType>(state: S) -> TimingSignal<S,T> {
		return	TimingSignal.DidBegin(StateSignal(state: state, by: .Session({state})))
	}
	static func willEndStateBySession<S,T: TransactionType>(state: S) -> TimingSignal<S,T> {
		return	TimingSignal.WillEnd(StateSignal(state: state, by: .Session({state})))
	}
	static func didBeginStateByTransaction<S,T: TransactionType>(state: S, transaction: T) -> TimingSignal<S,T> {
		return	TimingSignal.DidBegin(StateSignal(state: state, by: .Transaction({transaction})))
	}
	static func willEndStateByTransaction<S,T: TransactionType>(state: S, transaction: T) -> TimingSignal<S,T> {
		return	TimingSignal.WillEnd(StateSignal(state: state, by: .Transaction({transaction})))
	}
	static func didBeginStateByMutation<S,T: TransactionType>(state: S, mutation: T.Mutation) -> TimingSignal<S,T> {
		return	TimingSignal.DidBegin(StateSignal(state: state, by: .Mutation({mutation})))
	}
	static func willEndStateByMutation<S,T: TransactionType>(state: S, mutation: T.Mutation) -> TimingSignal<S,T> {
		return	TimingSignal.WillEnd(StateSignal(state: state, by: .Mutation({mutation})))
	}
}









































