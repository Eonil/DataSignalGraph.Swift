//
//  Test1.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/07/23/.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

#if os(osx)
    import SignalGraph
#endif
#if os(ios)
    import SignalGraphMobile
#endif






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
    
    
    run {
        let	x		=	Expect<Int>()
        let	v1		=	ValueStorage(111)
        func h1(timing: ValueStorage<Int>.Signal) {
            switch timing {
            case .DidBegin(let state):
                switch state() {
                case .Session(let s):
                    x.satisfy(1)
                case .Transaction(let t):
                    x.satisfy(2)
                case .Mutation(let m):
                    x.satisfy(3)
                }
            case .WillEnd(let state):
                switch state() {
                case .Mutation(let m):
                    x.satisfy(4)
                case .Transaction(let t):
                    x.satisfy(5)
                case .Session(let s):
                    x.satisfy(6)
                }
            }
        }
        
        x.expect([1])
        v1.register(ObjectIdentifier(x), handler: h1)
        x.check()
        
        
        x.expect([5,4,3,2])
        v1.snapshot    =   222
        x.check()
        
        x.expect([6])
        v1.deregister(ObjectIdentifier(x))
        x.check()
        
        assert(v1.state == 222)
    }
    run {
        let	x		=	Expect<Int>()
        let	v1		=	SetStorage([111,222,333])
        
        func h1(timing: SetStorage<Int>.Signal) {
            switch timing {
            case .DidBegin(let state):
                switch state() {
                case .Session(let s):
                    x.satisfy(1)
                case .Transaction(let t):
                    x.satisfy(2)
                case .Mutation(let m):
                    x.satisfy(3)
                }
            case .WillEnd(let state):
                switch state() {
                case .Mutation(let m):
                    x.satisfy(4)
                case .Transaction(let t):
                    x.satisfy(5)
                case .Session(let s):
                    x.satisfy(6)
                }
            }
        }
        
        x.expect([1])
        v1.register(ObjectIdentifier(x), handler: h1)
        x.check()
        
        x.expect([5,4,3,2])
        v1.insert(444)
        x.check()
        
        x.expect([5,4,3,2])
        v1.remove(222)
        x.check()
        
        x.expect([6])
        v1.deregister(ObjectIdentifier(x))
        x.check()
        
        x.expect([])
        v1.insert(999)
        x.check()
        
        assert(v1.snapshot == [111,333,444,999])
    }
    run {
        let	x		=	Expect<Int>()
        let	v1		=	ArrayStorage([111,222,333])
        
        func h1(timing: ArrayStorage<Int>.Signal) {
            switch timing {
            case .DidBegin(let state):
                switch state() {
                case .Session(let s):
                    x.satisfy(1)
                case .Transaction(let t):
                    x.satisfy(2)
                case .Mutation(let m):
                    x.satisfy(3)
                }
            case .WillEnd(let state):
                switch state() {
                case .Mutation(let m):
                    x.satisfy(4)
                case .Transaction(let t):
                    x.satisfy(5)
                case .Session(let s):
                    x.satisfy(6)
                }
            }
        }
        
        x.expect([1])
        v1.register(ObjectIdentifier(x), handler: h1)
        x.check()
        
        x.expect([5,4,3,2])
        v1.append(444)
        x.check()
        assert(v1.snapshot == [111,222,333,444])
        
        x.expect([5,4,3,2])
        v1.removeAtIndex(2)
        x.check()
        assert(v1.snapshot == [111,222,444])
        
        x.expect([6])
        v1.deregister(ObjectIdentifier(x))
        x.check()
        
        x.expect([])
        v1.insert(999, atIndex: 1)
        x.check()
        assert(v1.snapshot == [111,999,222,444])
    }
//    run {
//        let	x		=	Expect<Int>()
//        let	v1		=	ArrayStorage([111,222,333])
//        let	m1		=	ArrayMonitor<Int>()
//        m1.didInitiate		=	{ _ in x.satisfy(1) }
//        m1.didApply		=	{ _ in x.satisfy(2) }
//        m1.didAdd		=	{ _ in x.satisfy(3) }
//        m1.didBegin		=	{ _ in x.satisfy(4) }
//        m1.willEnd		=	{ _ in x.satisfy(5) }
//        m1.willRemove		=	{ _ in x.satisfy(6) }
//        m1.willApply		=	{ _ in x.satisfy(7) }
//        m1.willTerminate	=	{ _ in x.satisfy(8) }
//        
//        x.expect([1,4])
//        v1.register(m1)
//        x.check()
//        
//        x.expect([7,5,3,4,2])
//        v1.append(444)
//        x.check()
//        
//        x.expect([7,5,6,4,2])
//        v1.removeAtIndex(2)
//        x.check()
//        
//        x.expect([5,8])
//        v1.deregister(m1)
//        x.check()
//        
//        assert(v1.snapshot == [111,222,444])
//        
//        x.expect([])
//        v1.append(999)
//        x.check()
//        
//        assert(v1.snapshot == [111,222,444,999])
//    }
//    run {
//        let	x		=	Expect<Int>()
//        let	v1		=	DictionaryStorage([111: "A", 222: "B", 333: "C"])
//        let	m1		=	DictionaryMonitor<Int, String>()
//        m1.didInitiate		=	{ _ in x.satisfy(1) }
//        m1.didApply		=	{ _ in x.satisfy(2) }
//        m1.didAdd		=	{ _ in x.satisfy(3) }
//        m1.didBegin		=	{ _ in x.satisfy(4) }
//        m1.willEnd		=	{ _ in x.satisfy(5) }
//        m1.willRemove		=	{ _ in x.satisfy(6) }
//        m1.willApply		=	{ _ in x.satisfy(7) }
//        m1.willTerminate	=	{ _ in x.satisfy(8) }
//        
//        x.expect([1,4])
//        v1.register(m1)
//        x.check()
//        
//        x.expect([7,5,3,4,2])
//        v1[444]	=	"D"
//        x.check()
//        
//        x.expect([7,5,6,4,2])
//        v1.removeValueForKey(111)
//        x.check()
//        
//        x.expect([5,8])
//        v1.deregister(m1)
//        x.check()
//        
//        assert(v1.snapshot == [333: "C", 222: "B", 444: "D"])
//        
//        x.expect([])
//        v1.updateValue("E", forKey: 555)
//        x.check()
//        
//        assert(v1.snapshot == [555: "E", 333: "C", 222: "B", 444: "D"])
//    }
//    
//    run("DictionaryFilteringDictionaryStorage") {
//        let	x	=	Expect<Int>()
//        let	a1	=	DictionaryStorage<Int,String>([:])
//        let	a2	=	DictionaryFilteringDictionaryChannel<Int,String>()
//        a2.filter	=	{ k,v in return k % 2 == 0 }
//        let	m1	=	DictionaryMonitor<Int,String>()
//        m1.didInitiate		=	{ _ in x.satisfy(1) }
//        m1.didApply		=	{ _ in x.satisfy(2) }
//        m1.didAdd		=	{ _ in x.satisfy(3) }
//        m1.didBegin		=	{ _ in x.satisfy(4) }
//        m1.willEnd		=	{ _ in x.satisfy(5) }
//        m1.willRemove		=	{ _ in x.satisfy(6) }
//        m1.willApply		=	{ _ in x.satisfy(7) }
//        m1.willTerminate	=	{ _ in x.satisfy(8) }
//        
//        x.expect([])
//        a2.register(m1)
//        x.check()
//        
//        x.expect([1,4])
//        a1.register(ObjectIdentifier(a2)) 	{ a2.cast($0) }
//        x.check()
//        
//        x.expect([7,2])		//	Filter will filter out some muttions, but not transaction itself.
//        a1[111]	=	"AAA"
//        x.check()
//        assert(a1.snapshot == [111: "AAA"])
//        assert(a2.snapshot == [:])
//        
//        x.expect([7,2])		//	Filter will filter out some muttions, but not transaction itself.
//        a1[111]	=	nil
//        x.check()
//        assert(a1.snapshot == [:])
//        assert(a2.snapshot == [:])
//        
//        x.expect([7,2,7,5,3,4,2])
//        a1[111]	=	"AAA"
//        a1[222]	=	"BBB"
//        x.check()
//        assert(a1.snapshot == [111: "AAA", 222: "BBB"])
//        assert(a2.snapshot == [222: "BBB"])
//        
//        x.expect([7,2])
//        a1[111]	=	nil
//        x.check()
//        assert(a1.snapshot == [222: "BBB"])
//        assert(a2.snapshot == [222: "BBB"])
//        
//        x.expect([7,5,6,4,2])
//        a1[222]	=	nil
//        x.check()
//        assert(a1.snapshot == [:])
//        assert(a2.snapshot == [:])
//        
//        x.expect([5,8])
//        a1.deregister(ObjectIdentifier(a2))
//        x.check()
//        
//        x.expect([])
//        a2.deregister(m1)
//        x.check()
//    }
//    
//    run("DictionarySortingArray") {
//        run("Basics") {
//            let	x	=	Expect<Int>()
//            let	a1	=	DictionaryStorage<Int,String>([:])
//            let	a2	=	DictionaryOrderingArrayChannel<Int,String,Int>()
//            a2.order	=	{ $0.0 }
//            let	m1	=	ArrayMonitor<(Int,String)>()
//            m1.didInitiate		=	{ _ in x.satisfy(1) }
//            m1.didApply		=	{ _ in x.satisfy(2) }
//            m1.didAdd		=	{ _ in x.satisfy(3) }
//            m1.didBegin		=	{ _ in x.satisfy(4) }
//            m1.willEnd		=	{ _ in x.satisfy(5) }
//            m1.willRemove		=	{ _ in x.satisfy(6) }
//            m1.willApply		=	{ _ in x.satisfy(7) }
//            m1.willTerminate	=	{ _ in x.satisfy(8) }
//            
//            x.expect([])
//            a2.register(m1)
//            x.check()
//            
//            x.expect([1,4])
//            a1.register(ObjectIdentifier(a2)) 	{ a2.cast($0) }
//            x.check()
//            
//            x.expect([7,5,3,4,2])
//            a1[111]	=	"AAA"
//            x.check()
//            assert(a1.snapshot == [111: "AAA"])
//            assert(a2.snapshot == [(111,"AAA")])
//            
//            x.expect([7,5,6,4,2])
//            a1[111]	=	nil
//            x.check()
//            assert(a1.snapshot == [:])
//            assert(a2.snapshot == [])
//            
//            x.expect([7,5,3,4,2,7,5,3,4,2])
//            a1[111]	=	"AAA"
//            a1[222]	=	"BBB"
//            x.check()
//            assert(a1.snapshot == [111: "AAA", 222: "BBB"])
//            assert(a2.snapshot == [(111,"AAA"), (222,"BBB")])
//            
//            x.expect([7,5,6,4,2])
//            a1[111]	=	nil
//            x.check()
//            assert(a1.snapshot == [222: "BBB"])
//            assert(a2.snapshot == [((222,"BBB"))])
//            
//            x.expect([7,5,6,4,2])
//            a1[222]	=	nil
//            x.check()
//            assert(a1.snapshot == [:])
//            assert(a2.snapshot == [])
//            
//            x.expect([5,8])
//            a1.deregister(ObjectIdentifier(a2))
//            x.check()
//            
//            x.expect([])
//            a2.deregister(m1)
//            x.check()
//        }
//        run("Sorting") {
//            let	a1	=	DictionaryStorage<Int,String>([:])
//            let	a2	=	DictionaryOrderingArrayChannel<Int,String,Int>()
//            a2.order	=	{ $0.0 }
//            
//            a1.register(ObjectIdentifier(a2)) 	{ a2.cast($0) }
//            
//            a1[222]	=	"BBB"
//            a1[999]	=	"III"
//            a1[777]	=	"GGG"
//            a1[888]	=	"HHH"
//            assert(a2.snapshot == [(222,"BBB"), (777,"GGG"), (888,"HHH"), (999,"III")])
//            
//            a1.deregister(ObjectIdentifier(a2))
//        }
//    }
//    
//    run("ArrayMappingArrayStorage") {
//        let	x	=	Expect<Int>()
//        let	a1	=	ArrayStorage<Int>([])
//        let	a2	=	ArrayMappingArrayChannel<Int,String>()
//        a2.map		=	{ "V:\($0)" }
//        let	m1	=	ArrayMonitor<String>()
//        m1.didInitiate		=	{ _ in x.satisfy(1) }
//        m1.didApply		=	{ _ in x.satisfy(2) }
//        m1.didAdd		=	{ _ in x.satisfy(3) }
//        m1.didBegin		=	{ _ in x.satisfy(4) }
//        m1.willEnd		=	{ _ in x.satisfy(5) }
//        m1.willRemove		=	{ _ in x.satisfy(6) }
//        m1.willApply		=	{ _ in x.satisfy(7) }
//        m1.willTerminate	=	{ _ in x.satisfy(8) }
//        
//        x.expect([])
//        a2.register(m1)
//        x.check()
//        
//        x.expect([1,4])
//        a1.register(ObjectIdentifier(a2)) 	{ a2.cast($0) }
//        x.check()
//        
//        x.expect([7,5,3,4,2])
//        a1.append(999)
//        x.check()
//        assert(a1.snapshot == [999])
//        assert(a2.snapshot == ["V:999"])
//        
//        x.expect([7,5,6,4,2])
//        a1.removeAtIndex(0)
//        x.check()
//        assert(a1.snapshot == [])
//        assert(a2.snapshot == [])
//        
//        x.expect([5,8])
//        a1.deregister(ObjectIdentifier(a2))
//        x.check()
//        
//        x.expect([])
//        a2.deregister(m1)
//        x.check()
//    }
//    
//    run("`ValueMonitor` basics.") {
//        let	x		=	Expect<Int>()
//        let	v		=	ValueStorage<Int>(111)
//        let	m1		=	ValueMonitor<Int>()
//        m1.didInitiate		=	{ _ in x.satisfy(1) }
//        m1.didApply		=	{ _ in x.satisfy(2) }
//        m1.didAdd		=	{ _ in x.satisfy(3) }
//        m1.didBegin		=	{ _ in x.satisfy(4) }
//        m1.willEnd		=	{ _ in x.satisfy(5) }
//        m1.willRemove		=	{ _ in x.satisfy(6) }
//        m1.willApply		=	{ _ in x.satisfy(7) }
//        m1.willTerminate	=	{ _ in x.satisfy(8) }
//        
//        x.expect([1,4])
//        v.register(m1)
//        x.check()
//        
//        x.expect([7,5,6,3,4,2])
//        v.state	=	222
//        x.check()
//        assert(v.snapshot == 222)
//        
//        x.expect([5,8])
//        v.deregister(m1)
//        x.check()
//        
//        x.expect([])
//        v.state	=	333
//        x.check()
//        assert(v.state == 333)
//    }
    
    ///	Test replacement (update rather than separated insert and delete).
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








