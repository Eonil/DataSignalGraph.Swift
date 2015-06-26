//
//  Test.swift
//  ADHOC_SignalGraph3
//
//  Created by Hoon H. on 2015/06/26.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

protocol Continuable {
	func continuation() -> Self
}
extension Int: Continuable {
	func continuation() -> Int {
		return	self + 1
	}
}
class Expecting<T: Equatable> {
	init<S: SequenceType where S.Generator.Element == T>(_ steps: S) {
		var	g	=	steps.generate()
		generate	=	{ return g.next()! }
	}
	private(set) var	generate	:	()->T
	private(set) var	record		=	[T]()
	
	func assertAndContinue(state: T) {
		let	current	=	generate()
		assert(current == state)
		record.append(current)
	}
	func assertRecord(sample: [T]) {
		assert(record == sample)
	}
}
func run(@noescape f: ()->()) {
	f()
}
func testAll() {
	run {
//		let	exp		=	Expecting(0..<Int.max)
//		let	v1		=	ValueStorage(111)
//		let	m1		=	ValueMonitor<Int>()
//		m1.didInitiate		=	{ exp.assertAndContinue(0) }
//		m1.willTerminate	=	{ exp.assertAndContinue(1) }
//		v1.register(m1)
//		v1.deregister(m1)
//		exp.assertRecord([0,1])
	}
	run {
//		let	exp		=	Expecting([1,2,3,2,3,2,3,4])
//		let	v1		=	ValueStorage(111)
//		let	m1		=	ValueMonitor<Int>()
//		m1.didInitiate		=	{ exp.assertAndContinue(1) }
//		m1.willApply		=	{ _ in exp.assertAndContinue(2) }
//		m1.didApply		=	{ _ in exp.assertAndContinue(3) }
//		m1.willTerminate	=	{ exp.assertAndContinue(4) }
//		v1.register(m1)
//		exp.assertRecord([1,2,3])
//		v1.snapshot		=	222
//		exp.assertRecord([1,2,3,2,3])
//		v1.deregister(m1)
//		exp.assertRecord([1,2,3,2,3,2,3,4])
	}
	run {
		let	exp		=	Expecting([1,2,3,2,3,2,3,4,1,2])
		let	v1		=	SetStorage([111,222,333])
		let	m1		=	SetMonitor<Int>()
		m1.didInitiate		=	{ exp.assertAndContinue(1) }
		m1.didApply		=	{ _ in exp.assertAndContinue(3) }
		m1.didBegin		=	{ _ in exp.assertAndContinue(2) }
		
		m1.willEnd		=	{ _ in exp.assertAndContinue(3) }
		m1.willApply		=	{ _ in exp.assertAndContinue(2) }
		m1.willTerminate	=	{ exp.assertAndContinue(2) }
		
		v1.register(m1)
		exp.assertRecord([1,2])
		v1.insert(444)
		exp.assertRecord([1,2,3,2])
		v1.remove(222)
		exp.assertRecord([1,2,3,2,3,2])
		v1.deregister(m1)
		exp.assertRecord([1,2,3,2,3,2,3,4])
		assert(v1.snapshot == [111,333,444])
		
		v1.insert(999)
		exp.assertRecord([1,2,3,2,3,2,3,4])
		assert(v1.snapshot == [111,333,444,999])
	}
	run {
		let	exp		=	Expecting([1,2,3,2,3,2,3,4])
		let	v1		=	ArrayStorage([111,222,333])
		let	m1		=	ArrayMonitor<Int>()
		m1.didInitiate		=	{ exp.assertAndContinue(1) }
		m1.didBegin		=	{ _ in exp.assertAndContinue(2) }
		m1.willEnd		=	{ _ in exp.assertAndContinue(3) }
		m1.willTerminate	=	{ exp.assertAndContinue(4) }
		
		v1.register(m1)
		exp.assertRecord([1,2])
		v1.append(444)
		exp.assertRecord([1,2,3,2])
		v1.removeAtIndex(2)
		exp.assertRecord([1,2,3,2,3,2])
		v1.deregister(m1)
		exp.assertRecord([1,2,3,2,3,2,3,4])
		assert(v1.snapshot == [111,222,444])
		
		v1.append(999)
		exp.assertRecord([1,2,3,2,3,2,3,4])
		assert(v1.snapshot == [111,222,444,999])
	}
//	run {
//		let	exp		=	Expecting([1,2,3,2,3,2,3,2,3,4])
//		let	v1		=	DictionaryStorage([111: "A", 222: "B", 333: "C"])
//		let	m1		=	DictionaryMonitor<Int, String>()
//		m1.didInitiate		=	{ exp.assertAndContinue(1) }
//		m1.willApply		=	{ _ in exp.assertAndContinue(2) }
//		m1.didApply		=	{ _ in exp.assertAndContinue(3) }
//		m1.willTerminate	=	{ exp.assertAndContinue(4) }
//		
//		v1.register(m1)
//		exp.assertRecord([1,2,3])
//		v1.HOTFIX_subscript_set(444, value: "D")
//		exp.assertRecord([1,2,3,2,3])
//		v1.removeValueForKey(111)
//		exp.assertRecord([1,2,3,2,3,2,3])
//		v1.deregister(m1)
//		exp.assertRecord([1,2,3,2,3,2,3,2,3,4])
//		assert(v1.snapshot == [333: "C", 222: "B", 444: "D"])
//		
//		v1.updateValue("E", forKey: 555)
//		exp.assertRecord([1,2,3,2,3,2,3,2,3,4])
//		assert(v1.snapshot == [555: "E", 333: "C", 222: "B", 444: "D"])
//	}
}












