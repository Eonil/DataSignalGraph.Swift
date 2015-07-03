//
//  StatelessSignaling.swift
//  SG5
//
//  Created by Hoon H. on 2015/07/01.
//  Copyright © 2015 Eonil. All rights reserved.
//


public protocol Emittable {
	typealias	OutgoingSignal
	func register(identifier: ObjectIdentifier, handler: OutgoingSignal->())
	func deregister(identifier: ObjectIdentifier)
}
public protocol Sensible {
	typealias	IncomingSignal
	func cast(IncomingSignal)
}





public protocol StationType: class {
}
public protocol EmissiveStationType: StationType, Emittable {
	func register<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal>(S)
	func deregister<S: SensitiveStationType where S.IncomingSignal == OutgoingSignal>(S)
}
public protocol SensitiveStationType: StationType, Sensible {
}
public protocol RelayingStationType: SensitiveStationType, EmissiveStationType {
}
public protocol DelayingStationType: RelayingStationType {

}
///	Manually delaying station.
public protocol DeferringStationType: DelayingStationType {
	func wait()
	func go()
}




