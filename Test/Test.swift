//
//  Test.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/26.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import SignalGraph



class Expect<T: Equatable> {
	func expect(samples: [T]) {
		check()
		_samples.extend(samples)
	}
	func satisfy(sample: T) {
		assert(_samples.count > _records.count, "No more expectation. Current satistification should be a BUG.")
		assert(_samples[_records.count] == sample)
		_records.append(sample)
	}
	func check() {
		assert(_samples == _records, "Previous expectation has not be satisfied. There is a BUG in past satisfaction.")
		_samples	=	[]
		_records	=	[]
	}

	private var	_samples	=	[T]()
	private var	_records	=	[T]()
}










func run(_ name: String? = nil, @noescape f: ()->()) {
	f()
}
func testAll() {
	run {

		let	r	=	Relay<Int>()
		r.register(ObjectIdentifier(r)) { println($0) }
		r.cast(111)
		r.deregister(ObjectIdentifier(r))

	}
	run {
		let	exp		=	Expect<Int>()
		let	r		=	Relay<Int>()

		exp.expect([])
		r.register(ObjectIdentifier(r)) { exp.satisfy($0) }
		exp.check()

		exp.expect([123])
		r.cast(123)
		exp.check()

		exp.expect([])
		r.deregister(ObjectIdentifier(r))
		exp.check()
	}
	run {
		let	exp		=	Expect<Int>()
		let	st		=	Relay<Int>()
		let	ch		=	st
		let	mon		=	Monitor<Int>()

		mon.handler		=	{ exp.satisfy($0) }
		exp.expect([])
		st.register(mon)
		exp.check()

		exp.expect([123])
		st.cast(123)
		exp.check()

		exp.expect([])
		st.deregister(mon)
		exp.check()
	}
	//	run {
	//		let	exp		=	Expect<Int>()
	//		let	v1		=	StateStorage(111)
	//		let	m1		=	StateMonitor<Int>()
	//		m1.didInitiate		=	{ exp.assertAndRecord(0) }
	//		m1.willTerminate	=	{ exp.assertAndRecord(1) }
	//		v1.register(m1)
	//		v1.deregister(m1)
	//		exp.assertRecord([0,1])
	//	}
	//	run {
	//		let	exp		=	Expecting([1,2,3,2,3,2,3,4])
	//		let	v1		=	ValueStorage(111)
	//		let	m1		=	ValueMonitor<Int>()
	//		m1.didInitiate		=	{ exp.assertAndRecord(1) }
	//		m1.willApply		=	{ _ in exp.assertAndRecord(2) }
	//		m1.didApply		=	{ _ in exp.assertAndRecord(3) }
	//		m1.willTerminate	=	{ exp.assertAndRecord(4) }
	//		v1.register(m1)
	//		exp.assertRecord([1,2,3])
	//		v1.snapshot		=	222
	//		exp.assertRecord([1,2,3,2,3])
	//		v1.deregister(m1)
	//		exp.assertRecord([1,2,3,2,3,2,3,4])
	//	}
	run {
		let	x		=	Expect<Int>()
		let	v1		=	SetStorage([111,222,333])
		let	m1		=	SetTimingMonitor<Int>()
		m1.didInitiate		=	{ x.satisfy(1) }
		m1.didApply		=	{ _ in x.satisfy(2) }
		m1.didBegin		=	{ _ in x.satisfy(3) }
		m1.willEnd		=	{ _ in x.satisfy(4) }
		m1.willApply		=	{ _ in x.satisfy(5) }
		m1.willTerminate	=	{ x.satisfy(6) }

		x.expect([1,3])
		v1.register(m1)
		x.check()

		x.expect([4,5,2,3])
		v1.insert(444)
		x.check()

		x.expect([4,5,2,3])
		v1.remove(222)
		x.check()

		x.expect([4,6])
		v1.deregister(m1)
		x.check()

		x.expect([])
		v1.insert(999)
		x.check()

		assert(v1.snapshot == [111,333,444,999])
	}
	run {
		let	x		=	Expect<Int>()
		let	v1		=	ArrayStorage([111,222,333])
		let	m1		=	ArrayTimingMonitor<Int>()
		m1.didInitiate		=	{ x.satisfy(1) }
		m1.didApply		=	{ _ in x.satisfy(2) }
		m1.didBegin		=	{ _ in x.satisfy(3) }
		m1.willEnd		=	{ _ in x.satisfy(4) }
		m1.willApply		=	{ _ in x.satisfy(5) }
		m1.willTerminate	=	{ x.satisfy(6) }

		x.expect([1,3])
		v1.register(m1)
		x.check()

		x.expect([4,5,2,3])
		v1.append(444)
		x.check()

		x.expect([4,5,2,3])
		v1.removeAtIndex(2)
		x.check()

		x.expect([4,6])
		v1.deregister(m1)
		x.check()

		assert(v1.snapshot == [111,222,444])

		x.expect([])
		v1.append(999)
		x.check()

		assert(v1.snapshot == [111,222,444,999])
	}
	run {
		let	x		=	Expect<Int>()
		let	v1		=	DictionaryStorage([111: "A", 222: "B", 333: "C"])
		let	m1		=	DictionaryTimingMonitor<Int, String>()
		m1.didInitiate		=	{ x.satisfy(1) }
		m1.didApply		=	{ _ in x.satisfy(2) }
		m1.didBegin		=	{ _ in x.satisfy(3) }
		m1.willEnd		=	{ _ in x.satisfy(4) }
		m1.willApply		=	{ _ in x.satisfy(5) }
		m1.willTerminate	=	{ x.satisfy(6) }

		x.expect([1,3])
		v1.register(m1)
		x.check()

		x.expect([4,5,2,3])
		v1[444]	=	"D"
		x.check()

		x.expect([4,5,2,3])
		v1.removeValueForKey(111)
		x.check()

		x.expect([4,6])
		v1.deregister(m1)
		x.check()

		assert(v1.snapshot == [333: "C", 222: "B", 444: "D"])

		x.expect([])
		v1.updateValue("E", forKey: 555)
		x.check()

		assert(v1.snapshot == [555: "E", 333: "C", 222: "B", 444: "D"])
	}

	run("DictionaryFilteringDictionaryStorage") {
		let	x	=	Expect<Int>()
		let	a1	=	DictionaryStorage<Int,String>([:])
		let	a2	=	DictionaryFilteringDictionaryChannel<Int,String>()
		a2.filter	=	{ k,v in return k % 2 == 0 }
		let	m1	=	DictionaryTimingMonitor<Int,String>()
		m1.didInitiate		=	{ x.satisfy(1) }
		m1.didApply		=	{ _ in x.satisfy(2) }
		m1.didBegin		=	{ _ in x.satisfy(3) }
		m1.willEnd		=	{ _ in x.satisfy(4) }
		m1.willApply		=	{ _ in x.satisfy(5) }
		m1.willTerminate	=	{ x.satisfy(6) }

		x.expect([])
		a2.register(m1)
		x.check()

		x.expect([1,3])
		a1.register(ObjectIdentifier(a2)) 	{ a2.cast($0) }
		x.check()

		x.expect([4,5,2,3])
		a1[111]	=	"AAA"
		x.check()
		assert(a1.snapshot == [111: "AAA"])
		assert(a2.snapshot == [:])

		x.expect([4,5,2,3])
		a1[111]	=	nil
		x.check()
		assert(a1.snapshot == [:])
		assert(a2.snapshot == [:])

		x.expect([4,5,2,3,4,5,2,3])
		a1[111]	=	"AAA"
		a1[222]	=	"BBB"
		x.check()
		assert(a1.snapshot == [111: "AAA", 222: "BBB"])
		assert(a2.snapshot == [222: "BBB"])

		x.expect([4,5,2,3])
		a1[111]	=	nil
		x.check()
		assert(a1.snapshot == [222: "BBB"])
		assert(a2.snapshot == [222: "BBB"])

		x.expect([4,5,2,3])
		a1[222]	=	nil
		x.check()
		assert(a1.snapshot == [:])
		assert(a2.snapshot == [:])

		x.expect([4,6])
		a1.deregister(ObjectIdentifier(a2))
		x.check()

		x.expect([])
		a2.deregister(m1)
		x.check()
	}

	run("DictionarySortingArray") {
		run("Basics") {
			let	x	=	Expect<Int>()
			let	a1	=	DictionaryStorage<Int,String>([:])
			let	a2	=	DictionaryOrderingArrayChannel<Int,String,Int>()
			a2.order	=	{ $0.0 }
			let	m1	=	ArrayTimingMonitor<(Int,String)>()
			m1.didInitiate		=	{ x.satisfy(1) }
			m1.didApply		=	{ _ in x.satisfy(2) }
			m1.didBegin		=	{ _ in x.satisfy(3) }
			m1.willEnd		=	{ _ in x.satisfy(4) }
			m1.willApply		=	{ _ in x.satisfy(5) }
			m1.willTerminate	=	{ x.satisfy(6) }

			x.expect([])
			a2.register(m1)
			x.check()

			x.expect([1,3])
			a1.register(ObjectIdentifier(a2)) 	{ a2.cast($0) }
			x.check()

			x.expect([4,5,2,3])
			a1[111]	=	"AAA"
			x.check()
			assert(a1.snapshot == [111: "AAA"])
			assert(a2.snapshot == [(111,"AAA")])

			x.expect([4,5,2,3])
			a1[111]	=	nil
			x.check()
			assert(a1.snapshot == [:])
			assert(a2.snapshot == [])

			x.expect([4,5,2,3,4,5,2,3])
			a1[111]	=	"AAA"
			a1[222]	=	"BBB"
			x.check()
			assert(a1.snapshot == [111: "AAA", 222: "BBB"])
			assert(a2.snapshot == [(111,"AAA"), (222,"BBB")])

			x.expect([4,5,2,3])
			a1[111]	=	nil
			x.check()
			assert(a1.snapshot == [222: "BBB"])
			assert(a2.snapshot == [((222,"BBB"))])

			x.expect([4,5,2,3])
			a1[222]	=	nil
			x.check()
			assert(a1.snapshot == [:])
			assert(a2.snapshot == [])

			x.expect([4,6])
			a1.deregister(ObjectIdentifier(a2))
			x.check()

			x.expect([])
			a2.deregister(m1)
			x.check()
		}
		run("Sorting") {
			let	a1	=	DictionaryStorage<Int,String>([:])
			let	a2	=	DictionaryOrderingArrayChannel<Int,String,Int>()
			a2.order	=	{ $0.0 }

			a1.register(ObjectIdentifier(a2)) 	{ a2.cast($0) }

			a1[222]	=	"BBB"
			a1[999]	=	"III"
			a1[777]	=	"GGG"
			a1[888]	=	"HHH"
			assert(a2.snapshot == [(222,"BBB"), (777,"GGG"), (888,"HHH"), (999,"III")])

			a1.deregister(ObjectIdentifier(a2))
		}
	}

	run("ArrayMappingArrayStorage") {
		let	x	=	Expect<Int>()
		let	a1	=	ArrayStorage<Int>([])
		let	a2	=	ArrayMappingArrayChannel<Int,String>()
		a2.map		=	{ "V:\($0)" }
		let	m1	=	ArrayTimingMonitor<String>()
		m1.didInitiate		=	{ x.satisfy(1) }
		m1.didApply		=	{ _ in x.satisfy(2) }
		m1.didBegin		=	{ _ in x.satisfy(3) }
		m1.willEnd		=	{ _ in x.satisfy(4) }
		m1.willApply		=	{ _ in x.satisfy(5) }
		m1.willTerminate	=	{ x.satisfy(6) }

		x.expect([])
		a2.register(m1)
		x.check()

		x.expect([1,3])
		a1.register(ObjectIdentifier(a2)) 	{ a2.cast($0) }
		x.check()

		x.expect([4,5,2,3])
		a1.append(999)
		x.check()
		assert(a1.snapshot == [999])
		assert(a2.snapshot == ["V:999"])

		x.expect([4,5,2,3])
		a1.removeAtIndex(0)
		x.check()
		assert(a1.snapshot == [])
		assert(a2.snapshot == [])

		x.expect([4,6])
		a1.deregister(ObjectIdentifier(a2))
		x.check()

		x.expect([])
		a2.deregister(m1)
		x.check()
	}

	run("`ValueTimingMonitor` basics.") {
		let	x	=	Expect<Int>()
		let	v	=	ValueStorage<Int>(111)
		let	m	=	ValueTimingMonitor<Int>()
		m.didInitiate	=	{ x.satisfy(1) }
		m.didApply	=	{ _ in x.satisfy(2) }
		m.didBegin	=	{ _ in x.satisfy(3) }
		m.willEnd	=	{ _ in x.satisfy(4) }
		m.willApply	=	{ _ in x.satisfy(5) }
		m.willTerminate	=	{ x.satisfy(6) }

		x.expect([1,3])
		v.register(m)
		x.check()

		x.expect([4,5,2,3])
		v.state	=	222
		x.check()
		assert(v.snapshot == 222)

		x.expect([4,6])
		v.deregister(m)
		x.check()

		x.expect([])
		v.state	=	333
		x.check()
		assert(v.state == 333)
	}

//	run ("ExistenceMonitor family test.") {
//		run {
//			let	x	=	Expect<Int>()
//			let	v	=	ArrayStorage<Int>([])
//			let	m	=	ArrayExistenceMonitor<Int>()
//			m.didAdd	=	{ _ in x.satisfy(1) }
//			m.willRemove	=	{ _ in x.satisfy(2) }
//
//			x.expect([])
//			v.register(m)
//			x.check()
//
//			x.expect([1])
//			v.append(111)
//			x.check()
//
//			x.expect([1])
//			v.append(222)
//			x.check()
//
//			x.expect([1])
//			v.append(333)
//			x.check()
//
//			x.expect([2])
//			v.removeLast()
//			x.check()
//
//			x.expect([2,2])
//			v.deregister(m)
//			x.check()
//		}
//
//		run {
//			let	x	=	Expect<Int>()
//			let	v	=	ArrayStorage<Int>([111, 222])
//			let	m	=	ArrayExistenceMonitor<Int>()
//			m.didAdd	=	{ _ in x.satisfy(1) }
//			m.willRemove	=	{ _ in x.satisfy(2) }
//
//			x.expect([1,1])
//			v.register(m)
//			x.check()
//
//			x.expect([1])
//			v.append(333)
//			x.check()
//
//			x.expect([2,2,2])
//			v.removeAll()
//			x.check()
//
//			x.expect([])
//			v.deregister(m)
//			x.check()
//		}
//
//		run {
//			let	x	=	Expect<Int>()
//			let	v	=	ArrayStorage<Int>([111, 222])
//			let	m	=	ArrayExistenceMonitor<Int>()
//			m.didAdd	=	{ i in x.satisfy(i.1) }
//			m.willRemove	=	{ i in x.satisfy(i.1 * 10) }
//
//			x.expect([111, 222])
//			v.register(m)
//			x.check()
//
//			x.expect([333])
//			v.append(333)
//			x.check()
//
//			x.expect([3330])
//			v.removeLast()
//			x.check()
//
//			x.expect([2220, 1110])
//			v.deregister(m)
//			x.check()
//		}
//	}
}




private func == <K: Equatable,V: Equatable> (left: [(K,V)], right: [(K,V)]) -> Bool {
	if left.count != right.count {
		return	false
	}
	for i in 0..<left.count {
		if left[i].0 != right[i].0 {
			return	false
		}
		if left[i].1 != right[i].1 {
			return	false
		}
	}
	return	true
}








