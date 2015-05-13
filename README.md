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

>	If you set it up, you must tear it down.

State-ful signals needs strict explicit pairing of initiation and termination 
signals that are sent automatically at registration and deregistration of sensors.

There are two reasons why I always require this explicit deregistration.

-	I believe it makes a good habbit and resulting code.
-	Sensors are stored as a weak reference in emitters, and inaccessible in `deinit`.

The problem is Swift will nil-lize any weak references in `deinit`. So we cannot
access to the sensors in `deinit` of emitter, and then we have no way to send
termination signal when the emitter dies. Consequently, sensors cannot receive
termination signal, and this breaks basic premises of this framework.

To prevent this issue, I installed heavy assertions to ensure that you to deinstall
every sensors when the emitter dies. These assertions are activated at debug build,
and will be stripped away in release build.

Also, I believe requiring explicit deregistration is far better convention than 
implicit deregistration. So I expanded this to all implementations of signal emitters 
and sensors.














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

There are utility classes you will eventuall need for them.

-	`SignalMap`								Maps a source signals into destination signals.
-	`SignalFilter`							Filters to select a subset of signals.

These are utility classes for state-ful signals.

-	`ArrayEditor`							Provides array-like interface to a `ReplicatingArrayStorage`.
-	`DictionaryFilteringDictionaryStorage`	Maps a dictionary signal into a filtered subset of itself.
-	`DictionarySortingArrayStorage`			Maps a dictionary signal into a sorted array.
-	`ArraySignalMap`						Maps all values in the array signals into another type.
-	`StateHandler`							Provides simplified predefined state event handling points.























Credits & License
-----------------
This framework is written by Hoon H., and licensed under "MIT License".




