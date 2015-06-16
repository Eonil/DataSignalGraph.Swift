//
//  ValueStorage.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/05/05.
//  Copyright (c) 2015 Eonil. All rights reserved.
//




///	A dedicated dispatcher for value signal dispatch.
private final class ValueSignalDispatcher<T>: SignalDispatcher<ValueSignal<T>> {
	weak var owner: ValueStorage<T>?

	override func register(sensor: SignalSensor<ValueSignal<T>>) {
		Debugging.EmitterSensorRegistration.assertRegistrationOfStatefulChannelingSignaling((self, sensor))
		super.register(sensor)
		if let s = owner!._value {
			sensor.signal(ValueSignal.Initiation({s}))
		}
	}
	override func deregister(sensor: SignalSensor<ValueSignal<T>>) {
		Debugging.EmitterSensorRegistration.assertDeregistrationOfStatefulChannelingSignaling((self, sensor))
		if let s = owner!._value {
			sensor.signal(ValueSignal.Termination({s}))
		}
		super.deregister(sensor)
	}
}







///	A read-only proxy view of a repository.
///
public class ValueStorage<T>: StorageType {
	public var state: T {
		get {
			return	_value!
		}
	}
	
	public var emitter: SignalEmitter<ValueSignal<T>> {
		get {
			return	_dispatcher
		}
	}
	
	////
	
	private let _dispatcher		=	ValueSignalDispatcher<T>()
	
	private init() {
		_dispatcher.owner	=	self
	}
	deinit {
		_dispatcher.owner	=	nil
	}
	
	private var _value: T? {
		didSet {
			let	newValue	=	_value
			switch (oldValue, newValue) {
			case (nil, nil):	break
			case (nil, _):		_dispatcher.signal(ValueSignal.Initiation({newValue!}))
			case (_, nil):		_dispatcher.signal(ValueSignal.Termination({newValue!}))
			case (_, _):		_dispatcher.signal(ValueSignal.Transition({oldValue!}))
			}
		}
	}
}








///	A mutable value stroage that keep a state and provides methods to
///	manipulate the state.
public class EditableValueStorage<T>: ValueStorage<T> {
	public init(_ state: T) {
		super.init()
		super._value		=	state
	}
	deinit {
		emitter.assertNoRegisteredSensor()
		//	Do not send any signal.
		//	Because
		//
		//	1.	Any non-strong reference to self is inaccessible here.
		//	2.	We don't need to erase owning current state.
		//		Because users must already been removed all sensors from emitter.
		//		Emitter asserts no registered sensors when `deinit`ializes.
	}
	
	public override var state: T {
		get {
			return	super.state
		}
		set(v) {
			super._value	=	v
		}
	}
}







///	A value storage that reconstructs its state by signals.
///
///	This is conceptually a mutable storage. Mutation is performed by receiving 
///	explicit mutation signals. The sensor is the only mutator.
///
///	Contained state of this storage is "undefined" and inaccessible while you're
///	not binding sensor to an emitter. It is accessible only while it is being 
///	bound to an emitter.
///
public class ReplicatingValueStorage<T>: ValueStorage<T>, ReplicationType {
	public override init() {
		super.init()
		self._monitor.handler	=	{ [unowned self] s in
			switch s {
			case .Initiation(let s):
				self._value		=	s()
			case .Transition(let s):
				self._value		=	s()
			case .Termination(_):
				self._value		=	nil
			}
		}
	}
	
	public var sensor: SignalSensor<ValueSignal<T>> {
		get {
			return	_monitor
		}
	}
	
	////
	
	private let	_monitor	=	SignalMonitor<ValueSignal<T>>({ _ in })
}







///	A `ReplicatingValueStorage` that provides synchronous monitoring for each signals.
///
public class MonitoringValueStorage<T>: ReplicatingValueStorage<T> {
	public typealias	SignalHandler		=	ValueSignal<T> -> ()
	public var		willApplySignal		:	SignalHandler?
	public var		didApplySignal		:	SignalHandler?
	
	public override init() {
		super.init()
		let	applicator	=	self._monitor.handler
		self._monitor.handler	=	{ [weak self] s in
			self!.willApplySignal?(s)
			applicator(s)
			self!.didApplySignal?(s)
		}
	}
}









