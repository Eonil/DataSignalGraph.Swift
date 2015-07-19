////
////  AtomExistenceEmittable.swift
////  SignalGraph
////
////  Created by Hoon H. on 2015/07/19.
////  Copyright (c) 2015 Eonil. All rights reserved.
////
//
//import Foundation
//
//public protocol AtomExistenceEmittable: Emittable {
//	typealias	Element
//	func register(identifier: ObjectIdentifier, didAddHandler: Element->(), willRemoveHandler: Element->())
//	func deregister(identifier: ObjectIdentifier)
//}
//
//public extension ValueStorage: AtomExistenceEmittable {
//	public func register(identifier: ObjectIdentifier, didAddHandler: Element->(), willRemoveHandler: Element->()) {
//		register(identifier) {
//
//		}
//	}
//}
//public extension ArrayStorage: AtomExistenceEmittable {
//	public func register(identifier: ObjectIdentifier, didAddHandler: Element->(), willRemoveHandler: Element->()) {
//
//	}
//}
//public extension ValueStorage: AtomExistenceEmittable {
//	public func register(identifier: ObjectIdentifier, didAddHandler: Element->(), willRemoveHandler: Element->()) {
//
//	}
//}
//public extension ValueStorage: AtomExistenceEmittable {
//	public func register(identifier: ObjectIdentifier, didAddHandler: Element->(), willRemoveHandler: Element->()) {
//
//	}
//}