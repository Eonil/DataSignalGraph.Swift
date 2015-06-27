//
//  Test.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/26.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

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








func run(@noescape f: ()->()) {
	f()
}
func testAll() {
	run {
		let	exp		=	Expect<Int>()
		let	ch		=	SignalCaster<Int>()

		exp.expect([])
		ch.register(ObjectIdentifier(ch)) { exp.satisfy($0) }
		exp.check()

		exp.expect([123])
		ch.cast(123)
		exp.check()

		exp.expect([])
		ch.deregister(ObjectIdentifier(ch))
		exp.check()
	}
	run {
		let	exp		=	Expect<Int>()
		let	ch		=	SignalCaster<Int>()
		let	mon		=	SignalMonitor<Int>()

		mon.handler		=	{ exp.satisfy($0) }
		exp.expect([])
		ch.register(mon)
		exp.check()

		exp.expect([123])
		ch.cast(123)
		exp.check()

		exp.expect([])
		ch.deregister(mon)
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
		let	m1		=	SetMonitor<Int>()
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
		let	m1		=	ArrayMonitor<Int>()
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
		let	m1		=	DictionaryMonitor<Int, String>()
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
}












