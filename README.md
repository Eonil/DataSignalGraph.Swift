SignalGraph
===========
2015.06.27
Hoon H.


`SignalGraph` provides several stuffs.

-	Sending state-less signals. (`SignalChannel` class)
-	Sending simple mutation signals. (`StateStorage` class)
-	Sending collection mutation signals. (`SetStorage`, `ArrayStorage`, `DictionaryStorage` classes)
-	Sending filtering, sorting and mapping of collection entries.
	
	-	`DictionaryFilteringDictionaryStorage` class.
	-	`DictionarySortingArrayStorage` class.
	-	`ArrayMappingArrayStorage` class.

Getting Started
---------------
This is typical setup of signal graph.

	DictionaryStorage
	->	DictionaryFilteringDictionaryStorage
	->	DictionarySortingArrayStorage
	->	ArrayMappingArrayStorage






Credits & License
-----------------
This library is written by Hoon H., and licensed under "MIT License".