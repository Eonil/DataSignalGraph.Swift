SignalGraph
===========
2015.06.27
Hoon H.


`SignalGraph` provides several stuffs.

-	Sending state-less signals. (`Relay`, `Monitor` class)
-	Sending simple mutation signals. (`ValueStorage` class)
-	Sending collection mutation signals. (`SetStorage`, `ArrayStorage`, `DictionaryStorage` classes)
-	Sending filtering, sorting and mapping of collection entries.
	
	-	`DictionaryFilteringDictionaryChannel` class.
	-	`DictionarySortingArrayStorageChannel` class.
	-	`ArrayMappingArrayStorageChannel` class.

-	Hiding mutators by wrapping storage. (`WeakChannel` type)

Getting Started
---------------
This is typical setup of signal graph.

	DictionaryStorage
	->	DictionaryFilteringDictionaryChannel
	->	DictionarySortingArrayChannel
	->	ArrayMappingArrayChannel
	->	ArrayMonitor






Credits & License
-----------------
This library is written by Hoon H., and licensed under "MIT License".