//
//  Signal.swift
//  SG2
//
//  Created by Hoon H. on 2015/06/21.
//  Copyright © 2015 Eonil. All rights reserved.
//




//public protocol EmitterType {
//	typealias	Signal
//}
//public protocol ChannelType: EmitterType  {
//	typealias	Sensor	:	SensorType
//	func register(sensor: Sensor)
//	func deregister(sensor: Sensor)
//}
////public extension ChannelType where Sensor.Signal == Signal {
////	func register(sensor: Sensor)
////	func deregister(sensor: Sensor)
////}
//public protocol SensorType {
//	typealias	Signal
//}
//public protocol MonitorType: SensorType {
//}











public class SignalEmitter<T> {
	func transfer(signal: T) {
		for monitor in _sensorBoxes {
			assert(monitor.object != nil)
			monitor.object!.transfer({signal})
		}
	}
	
	func register(sensor: SignalSensor<T>) {
		_sensorBoxes.append(_WeakBox(object: sensor))
		sensor._online	=	true
	}
	
	func deregister(sensor: SignalSensor<T>) {
		sensor._online	=	false
//		_sensorBoxes.removeAtIndex(_sensorBoxes.indexOf({ $0.object === sensor })!)		//	For Swift 2.
		_sensorBoxes.removeAtIndex(_indexOf(_sensorBoxes, { $0.object === sensor })!)
	}
	
	///
	
	private var	_sensorBoxes	=	[_WeakBox<SignalSensor<T>>]()
}
private struct _WeakBox<T: AnyObject> {
	weak var object: T?
}
private func _indexOf<T>(array: [T], predicate: (T->Bool)) -> Int? {
	for i in 0..<array.count {
		let	e	=	array[i]
		if predicate(e) {
			return	i
		}
	}
	return	nil
}



public class SignalSensor<T> {
	///	Handles all signals as is sent to this monitor.
	var handler: (T->())?
	
	func transfer(signal: ()->T) {
		handler?(signal())
	}
	
	///
	
	private var	_online	=	false
}














public class SignalChannel<T>: SignalEmitter<T> {
	public override func register(sensor: SignalSensor<T>) {
		super.register(sensor)
	}
	
	public override func deregister(sensor: SignalSensor<T>) {
		super.deregister(sensor)
	}
}
public class SignalDispatcher<T>: SignalChannel<T> {
	public override func transfer(signal: T) {
		super.transfer(signal)
	}
}









//public protocol SensorType {
//	typealias	Signal
//	var handler: (Signal->())? { get set }
//}

///	You can use `SignalSensor` if you want to expose only registering/deregistering
///	and hide `transfer` method.
public class SignalMonitor<T>: SignalSensor<T> {
	public override var handler: (T->())? {
		willSet {
			
		}
	}
}







