SignalGraph.Swift
=====================
2015/05/09
Hoon H.




Provides components to build data signal graphs to define data processing in declarative 
manner.







Usage
-----

Usually, front-end applications will be configured like this.

	*	EditableDictionaryStorage						Stores origin data model values.
		->	DictionaryFilteringDictionaryStorage		Filter it.
			->	DictionarySortingArrayStorage			Sort it.
				->	ArraySignalMapStorage				Convert into view model values.







Rules
-----

>	Clarity is far more important than shorter code.

Short code is important. Because it provides better readability. But clarity is far 
more important than the readability. 

>	If you set it up, you must tear it down yourself.

If you call `register`, then you must call a paired `deregister`. No exception.
This is a policy, but there's also a technical reason. I simply cannot deregister
sensors automatically in `deinit` due to nil-lization of weak references in Swift.
Anyway, don't worry too much. This framework will fire errors if you forgot
deregistration in debug build.















State-ful Signals
-----------------
State-ful signals presume you're sening signals to represent mutable state, and
represent it by sening multiple states over time. It also presumes you cannot 
access the signal origin, so you cannot get current state of the origin.

With these premises, signals are designed to allow receivers can reconstruct full
state by accumulating them. To make tracking easier, signals are usually sent in
form of mutation commands rather then state snapshot.

State signals usually have three cases. 

-	Initiation
-	Transition
-	Termination

Please note that signals does not provides timing information. A transition can be
sent before or after the actual transition happens, and source state can actually
be non-existent. So you shouldn't depend on the timing of signal receiving, and 
should reconstruct everything only from the information passed with the signal 
itself.

Transition passes mutation command instead of state snapshot. This is mainly for
optimization. Because you usually need to transform signals, and passing full state
snapshot usually means full conversion that is usually inacceptable cost.

If you think there're too many mutations so sending snapshot is faster, then you
can send pair of termination/initiation signals instead of. Which means resetting 
by snapshot that means semantically same with sening full snapshot state.
So transition signal can be thought as a kind of optimization.








Type Roles and Hierarchy
------------------------

-	*Gate*						--	Defines in/out signal types.
	-	*Emitter*				--	A signal sender.
		-	*Dispatcher*		--	An initial emitter that exposes a method to send signals actually.
	-	*Sensor*				--	A signal receiver
		-	*Monitor*			--	A terminal sensor.

-	*Storage*					--	A read-only state view that emits state mutation signals.
	-	*Replication*			--	A storage that receives mutation signals to reconstruct state.
		-	*Slot*				--	A replication that allows you to edit the value directly.
									And you cannot send signals to this type objects.

See `Protocols.swift` for details. It also serves as a documentation for each concepts.

Emitter/sensor protocols does not define uni/multi-casting/catching behaviors.
But implementations can define specific limitations. 

-	`SignalEmitter`				A multicasting emitter. This can fire to multiple sensors.
-	`SignalSensor`				A unicatching sensor. This can observe only one emitter.

Storage and replication roles are implemented by these specialized classes.
These implementations require multicasting emitter and unicatching sensor, and using default
implementation of signal emitter and signal sensor.

-	`ValueStorage`				A single value storage.
-	`SetStorage`				A multiple unique value (key) storage.
-	`DictionaryStorage`			A multiple key/value pair storage.
-	`ArrayStorage`				A multiple index/value pair storage. Index is treated as a 
								specialized key.

There are utility classes you will eventually feel need for them.

-	`SignalMap`								Maps a source signals into destination signals.
-	`SignalFilter`							Filters to select a subset of signals.

Also for state-ful signals.

-	`DictionaryFilteringDictionaryStorage`	Provides a filtered subset from signals from a dictionary.
-	`DictionarySortingArrayStorage`			Provides a sorted array from signals from a dictionary.
-	`ArraySignalMap`						Maps all values in array signals into another type.
-	`StateHandler`							Provides simplified predefined state event handling points.























Credits & License
-----------------
This framework is written by Hoon H., and licensed under "MIT License".




