SignalGraph.Swift
=====================
2015/05/09
Hoon H.


**ACTIVELY UNDER CONSTRUCTION, AND UNSTABLE. I DON'T RECOMMEND TO USE THIS LIBRARY FOR PRODUCTION USE YET.**



Provides components to build data signal graphs to define data processing pipeline in
a declarative manner.





Getting Started
---------------

(to be filled...)








Concepts
--------

Core concept of this library is signals data types. Basically a signal is state-less
value to represent parameters of each message.

This signal exnteded further to represent stateful value. This state-ful signal is
divided into four kinds -- value, set, array, dictionary. Core coneptual point of
these signals is that you can reconstruct full state by only observing the signal.
You don't have to access state source to reconstrcut the state. So by this, you can
truly *decouple* the state source and state observer. To make de-coupling complete,
this doesn't even provide timing synchronicity.

This library provides several facilities to handle those signals. Basically each 
signal types have corresponding these handling class set.

-	`~Storage`		Abstract class of read-only container that can 
				produce mutating signals.

-	`Editable~Storage`	A container that keeps a mutable state and directly 
				editable.

-	`Replicating~Storage`	A container that synchronizes its state with signals.

-	`Monitoring~Storage`	A `Replicating~Storage` that provides *synchronous*
				hooks for each signals. 

You can connect `Replicating~Storage` to observe any `~Storage` to make it to be 
synchronized with it. 

	Editable~Storage -> ~Replicating~Storage
	~Replicating~Storage -> ~Replicating~Storage
	Editable~Storage -> ~Replicating~Storage -> ~Replicating~Storage

Contained state of a storage is defined only while it is registered to another signal
source. Otherwise, state is undefined and inaccessible. Trial to access it will cause
a runtime error.
`Editable~Storage` maintains its own state by itself, and cannot observe another 
signal source.
`Monitoring~Storage` is recommended way to handling signals for reactions. 

Here's typical storage configuration.

	*	EditableValueStorage		
	->	MonitoringValueStorage

**NOTE**	Take care that you don't have synchronicity guarantee between 
		`EditableValueStorage` and `MonitoringValueStorage`. Though 
		`MonitoringValueStorage` provides synchronous monitoring, but it is
		about signal application timing to itself, and nothing related to 
		its source -- `EditableValueStorage`.

`Monitoring~Storage` is unicast only. If you need multicasting to multiple handlers,
you can choose one of these.

1.	Make multiple monitoring storage. Simple, clear but asynchronous.
	This is recommended way. 
2.	Route to multiple handlers in the handler yourself if you need absolute 
	synchronicity between all handlers.










License & Credits
-----------------
This framework is written by Hoon H., and licensed under "MIT License".












