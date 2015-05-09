//
//  Debugging.swift
//  Channel3
//
//  Created by Hoon H. on 2015/05/09.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

class Debugging {
	struct EmitterSensorRegistration {
		typealias	Pair	=	(emitter: AnyObject, sensor: AnyObject)
		static func assertRegistrationOfStatefulChannelingSignaling(p: Pair) {
			assert(Debugging.EmitterSensorRegistration.lookupPairWithSensor(p.sensor) == nil, "Specified sensor `\(p.sensor)` must be a state-ful channeling sensor, so it can be connected to only one emitter at a time.")
			recordPair(p)
		}
		static func assertDeregistrationOfStatefulChannelingSignaling(p: Pair) {
			assert(lookupPairWithSensor(p.sensor) != nil)
			assert(lookupPairWithSensor(p.sensor)!.emitter === p.emitter, "The only registered emitter of the sensor `\(p.sensor)` must be emitter `\(p.emitter)`.")
			erasePair(p)
		}
		
		////
		
		private static func recordPair(pair: Pair) {
			sensorToPair[ObjectIdentifier(pair.sensor)]	=	pair
		}
		private static func erasePair(pair: Pair) {
			sensorToPair.removeValueForKey(ObjectIdentifier(pair.sensor))
		}
		private static func lookupPairWithSensor(s: AnyObject) -> Pair? {
			return	sensorToPair[ObjectIdentifier(s)]
		}
		
		////
		
		private static var	sensorToPair	=	[:] as [ObjectIdentifier: Pair]
	}
}

