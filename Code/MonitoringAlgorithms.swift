////
////  MonitoringAlgorithms.swift
////  SignalGraph
////
////  Created by Hoon H. on 2015/06/28.
////  Copyright (c) 2015 Eonil. All rights reserved.
////
//
//
/////	Monitoring notification routing algorithms for `didAdd`/`willRemove` pair.
/////
//struct MonitoringAlgorithms {
//
//	static func route<T, M: ExistenceMonitorType where M.Entry == T>(signal: StateSignal<T,ValueTransaction<T>>, to monitor: M) {
//		switch signal.timing {
//		case .DidBegin:
//			if let didAdd = monitor.didAdd {
//				switch signal.by {
//				case .Session(let s):
//					didAdd(s())
//				case .Transaction(let t):
//					if let last = t().mutations.last {
//						didAdd(last.future)
//					}
//				case .Mutation(let m):
//					break
//				}
//			}
//
//		case .WillEnd:
//			if let willRemove = monitor.willRemove {
//				switch signal.by {
//				case .Mutation(let m):
//					break
//				case .Transaction(let t):
//					if let last = t().mutations.last {
//						willRemove(last.past)
//					}
//				case .Session(let s):
//					willRemove(s())
//				}
//			}
//		}
//	}
//
//	static func route<T: Hashable, M: ExistenceMonitorType where M.Entry == (T,())>(signal: StateSignal<Set<T>,CollectionTransaction<T,()>>, to monitor: M) {
//		switch signal.timing {
//		case .DidBegin:
//			if let didAdd = monitor.didAdd {
//				switch signal.by {
//				case .Session(let s):
//					for a in s() {
//						didAdd(a, ())
//					}
//				case .Transaction(let t):
//					for m in t().mutations {
//						switch m {
//						case (_, nil, nil):	fatalError()
//						case (_, nil, _):	didAdd(m.identity, m.future!)
//						case (_, _, nil):	break
//						case (_, _, _):		didAdd(m.identity, m.future!)
//						}
//					}
//				case .Mutation(let m):
//					break
//				}
//			}
//
//		case .WillEnd:
//			if let willRemove = monitor.willRemove {
//				switch signal.by {
//				case .Mutation(let m):
//					break
//				case .Transaction(let t):
//					for m in t().mutations {
//						switch m {
//						case (_, nil, nil):	fatalError()
//						case (_, nil, _):	break
//						case (_, _, nil):	willRemove(m.identity, m.past!)
//						case (_, _, _):		willRemove(m.identity, m.past!)
//						}
//					}
//				case .Session(let s):
//					for a in s() {
//						willRemove(a, ())
//					}
//				}
//			}
//		}
//	}
//
//	static func route<T, M: ExistenceMonitorType where M.Entry == (Int,T)>(signal: StateSignal<[T],CollectionTransaction<Int,T>>, to monitor: M) {
//		switch signal.timing {
//		case .DidBegin:
//			if let didAdd = monitor.didAdd {
//				switch signal.by {
//				case .Session(let s):
//					for i in 0..<signal.state.count {
//						didAdd(i, signal.state[i])
//					}
//
//				case .Transaction(let t):
//					for m in t().mutations {
//						switch m {
//						case (_, nil, nil):	fatalError()
//						case (_, nil, _):	didAdd(m.identity, m.future!)
//						case (_, _, nil):	break
//						case (_, _, _):		didAdd(m.identity, m.future!)
//						}
//					}
//
//				case .Mutation(let m):
//					break
//				}
//			}
//
//		case .WillEnd:
//			if let willRemove = monitor.willRemove {
//				switch signal.by {
//				case .Mutation(let m):
//					break
//
//				case .Transaction(let t):
//					for m in t().mutations {
//						switch m {
//						case (_, nil, nil):	fatalError()
//						case (_, nil, _):	break
//						case (_, _, nil):	willRemove(m.identity, m.past!)
//						case (_, _, _):		willRemove(m.identity, m.past!)
//						}
//					}
//
//				case .Session(let s):
//					for i in reverse(0..<signal.state.count) {
//						willRemove(i, signal.state[i])
//					}
//				}
//			}
//		}
//	}
//
//	static func route<K: Hashable, V, M: ExistenceMonitorType where M.Entry == (K,V)>(signal: StateSignal<[K:V],CollectionTransaction<K,V>>, to monitor: M) {
//		switch signal.timing {
//		case .DidBegin:
//			if let didAdd = monitor.didAdd {
//				switch signal.by {
//				case .Session(let s):
//					for (k,v) in signal.state {
//						didAdd(k, v)
//					}
//				case .Transaction(let t):
//					for m in t().mutations {
//						switch m {
//						case (_, nil, nil):	fatalError()
//						case (_, nil, _):	didAdd(m.identity, m.future!)
//						case (_, _, nil):	break
//						case (_, _, _):		didAdd(m.identity, m.future!)
//						}
//					}
//				case .Mutation(let m):
//					break
//				}
//			}
//
//		case .WillEnd:
//			if let willRemove = monitor.willRemove {
//				switch signal.by {
//				case .Mutation(let m):
//					break
//
//				case .Transaction(let t):
//					for m in t().mutations {
//						switch m {
//						case (_, nil, nil):	fatalError()
//						case (_, nil, _):	break
//						case (_, _, nil):	willRemove(m.identity, m.past!)
//						case (_, _, _):		willRemove(m.identity, m.past!)
//						}
//					}
//				case .Session(let s):
//					for (k,v) in signal.state {
//						willRemove(k, v)
//					}
//				}
//			}
//		}
//	}
//}
//
//
//
//
//
//
//
//
