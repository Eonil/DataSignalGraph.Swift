//
//  MonitoringAlgorithms.swift
//  SignalGraph
//
//  Created by Hoon H. on 2015/06/28.
//  Copyright (c) 2015 Eonil. All rights reserved.
//


///	Monitoring notification routing algorithms for `didAdd`/`willRemove` pair.
///
struct MonitoringAlgorithms {

	static func route<T, M: ExistenceMonitorType where M.Entry == T>(signal: StateSignal<T,ValueTransaction<T>>, to monitor: M) {
		switch signal.timing {
		case .DidBegin:
			if let didAdd = monitor.didAdd {
				switch signal.by {
				case nil:	didAdd(signal.state)
				case _:
					if let last = signal.by!.mutations.last {
						didAdd(last.future)
					}
				}
			}

		case .WillEnd:
			if let willRemove = monitor.willRemove {
				switch signal.by {
				case nil:	willRemove(signal.state)
				case _:
					if let last = signal.by!.mutations.last {
						willRemove(last.past)
					}
				}
			}
		}
	}

	static func route<T: Hashable, M: ExistenceMonitorType where M.Entry == (T,())>(signal: StateSignal<Set<T>,CollectionTransaction<T,()>>, to monitor: M) {
		switch signal.timing {
		case .DidBegin:
			if let didAdd = monitor.didAdd {
				switch signal.by {
				case nil:
					for a in signal.state {
						didAdd(a, ())
					}

				case _:
					for m in signal.by!.mutations {
						switch m {
						case (_, nil, nil):	fatalError()
						case (_, nil, _):	didAdd(m.identity, m.future!)
						case (_, _, nil):	break
						case (_, _, _):		didAdd(m.identity, m.future!)
						}
					}
				}
			}

		case .WillEnd:
			if let willRemove = monitor.willRemove {
				switch signal.by {
				case nil:
					for a in signal.state {
						willRemove(a, ())
					}

				case _:
					for m in signal.by!.mutations {
						switch m {
						case (_, nil, nil):	fatalError()
						case (_, nil, _):	break
						case (_, _, nil):	willRemove(m.identity, m.past!)
						case (_, _, _):		willRemove(m.identity, m.past!)
						}
					}
					
				}
			}
		}
	}

	static func route<T, M: ExistenceMonitorType where M.Entry == (Int,T)>(signal: StateSignal<[T],CollectionTransaction<Int,T>>, to monitor: M) {
		switch signal.timing {
		case .DidBegin:
			if let didAdd = monitor.didAdd {
				switch signal.by {
				case nil:
					for i in 0..<signal.state.count {
						didAdd(i, signal.state[i])
					}

				case _:
					for m in signal.by!.mutations {
						switch m {
						case (_, nil, nil):	fatalError()
						case (_, nil, _):	didAdd(m.identity, m.future!)
						case (_, _, nil):	break
						case (_, _, _):		didAdd(m.identity, m.future!)
						}
					}
				}
			}

		case .WillEnd:
			if let willRemove = monitor.willRemove {
				switch signal.by {
				case nil:
					for i in reverse(0..<signal.state.count) {
						willRemove(i, signal.state[i])
					}

				case _:
					for m in signal.by!.mutations {
						switch m {
						case (_, nil, nil):	fatalError()
						case (_, nil, _):	break
						case (_, _, nil):	willRemove(m.identity, m.past!)
						case (_, _, _):		willRemove(m.identity, m.past!)
						}
					}

				}
			}
		}
	}

	static func route<K: Hashable, V, M: ExistenceMonitorType where M.Entry == (K,V)>(signal: StateSignal<[K:V],CollectionTransaction<K,V>>, to monitor: M) {
		switch signal.timing {
		case .DidBegin:
			if let didAdd = monitor.didAdd {
				switch signal.by {
				case nil:
					for (k,v) in signal.state {
						didAdd(k, v)
					}

				case _:
					for m in signal.by!.mutations {
						switch m {
						case (_, nil, nil):	fatalError()
						case (_, nil, _):	didAdd(m.identity, m.future!)
						case (_, _, nil):	break
						case (_, _, _):		didAdd(m.identity, m.future!)
						}
					}
				}
			}

		case .WillEnd:
			if let willRemove = monitor.willRemove {
				switch signal.by {
				case nil:
					for (k,v) in signal.state {
						willRemove(k, v)
					}

				case _:
					for m in signal.by!.mutations {
						switch m {
						case (_, nil, nil):	fatalError()
						case (_, nil, _):	break
						case (_, _, nil):	willRemove(m.identity, m.past!)
						case (_, _, _):		willRemove(m.identity, m.past!)
						}
					}

				}
			}
		}
	}

}








