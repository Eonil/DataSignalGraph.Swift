SignalGraph
===========
2015.06.27
Hoon H.


`SignalGraph` provides several stuffs.

-	Sending state-less signals. (`Relay`, `Monitor` class)
-	Sending mutation signals for single value. (`ValueStorage` class)
-	Sending mutation signals for value collection. (`SetStorage`, `ArrayStorage`, `DictionaryStorage` classes)
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
    ->  WeakChannel





Credits & License
-----------------
This library is written by Hoon H., and licensed under "MIT License".