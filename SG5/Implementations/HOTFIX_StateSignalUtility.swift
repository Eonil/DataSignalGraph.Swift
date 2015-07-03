//
//  HOTFIX_StateSignalUtility.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/01.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation

///	Exists because Swift 1.x cannot support multi-type enum and that makes 
///	signal building overly complex more than it should be.
struct HOTFIX_StateSignalUtility {
	static func didBeginStateBySession<S,T: TransactionType>(state: S) -> StateSignal<S,T> {
		return	StateSignal.DidBegin(state: {state}, by: {StateSignalingCause<S,T>.Session({state})})
	}
	static func willEndStateBySession<S,T: TransactionType>(state: S) -> StateSignal<S,T> {
		return	StateSignal.DidBegin(state: {state}, by: {StateSignalingCause<S,T>.Session({state})})
	}
	static func didBeginStateByTransaction<S,T: TransactionType>(state: S, transaction: T) -> StateSignal<S,T> {
		return	StateSignal.DidBegin(state: {state}, by: {StateSignalingCause<S,T>.Transaction({transaction})})
	}
	static func willEndStateByTransaction<S,T: TransactionType>(state: S, transaction: T) -> StateSignal<S,T> {
		return	StateSignal.WillEnd(state: {state}, by: {StateSignalingCause<S,T>.Transaction({transaction})})
	}
	static func didBeginStateByMutation<S,T: TransactionType>(state: S, mutation: T.Mutation) -> StateSignal<S,T> {
		return	StateSignal.DidBegin(state: {state}, by: {StateSignalingCause<S,T>.Mutation({mutation})})
	}
	static func willEndStateByMutation<S,T: TransactionType>(state: S, mutation: T.Mutation) -> StateSignal<S,T> {
		return	StateSignal.WillEnd(state: {state}, by: {StateSignalingCause<S,T>.Mutation({mutation})})
	}
}









































