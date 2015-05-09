DataSignalGraph.Swift
=====================
2015/05/09
Hoon H.




Provides components to build data signal graphs to define data processing in declarative 
manner.







Usage
-----


-	Make a `~Replication`. These classes work as main data container in this framework.
	Looks like a bit wired name, but you will see why it named in that way soon.











Type Roles and Hierarchy
------------------------

-	*Gate*						--	Defines in/out signal types.
	-	*Emitter*				--	A signal sender.
		-	*Dispatcher*		--	An initial emitter that exposes a method to send signals actually.
	-	*Sensor*				--	A signal receiver
		-	*Monitor*			--	A terminal sensor.

-	*Storage*					--	A read-only state view that emits state mutation signals.
	-	*Replication*			--	A storage that receives mutation signals to reconstruct state.

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

-	`SignalMap`							Maps a source signals into destination signals.
-	`SignalFilter`						Filters to select a subset of signals.
-	`ArrayEditor`						Provides array-like interface to a `ArrayReplication`.
-	`DictionarySignalSortingArrayMap`	Maps a dictionary signal into a sorted array.








Credits & License
-----------------
This framework is written by Hoon H., and licensed under "MIT License".




