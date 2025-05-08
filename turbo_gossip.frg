#lang forge/temporal

/*
This file models that most complex gossip protocol, where there can be multiple rumor spreaders
spreading multiple rumors at once, where the rumors are spread at different rates (i.e. rumors 
can be remain unspread in a given round). Rumors spread at an exponential rate.
*/

option max_tracelength 14
option min_tracelength 6
option no_overflow true
option run_sterling "simple_gossip_vis.js"

one sig System {}

abstract sig Node {
    var heardRumors: set Rumor
}

sig Rumor {}

sig RumorSpreader extends Node {
    var baseRumors: set Rumor
}

sig RumorListener extends Node {}

// this predicate ensures that each rumor is only spread by one rumor spreader
// and that the baseRumors are persistent across time stamps
pred wellformed {
    all disj rs1, rs2: RumorSpreader | #{{rs1.baseRumors} & {rs2.baseRumors}} = 0
    all rs: RumorSpreader { 
        rs.baseRumors = rs.baseRumors'
    }
}

// this predicate ensures that in the initial state, no listeners have heard any rumors
// every rumor belongs to one rumor spreader and has been heard by that rumor spreader
pred initialRumor[r: Rumor] {
    all rl: RumorListener | {
        r not in rl.heardRumors
    }
    one rs: RumorSpreader | {
        r in rs.baseRumors
    }
    all rs: RumorSpreader | {
        r in rs.baseRumors <=> r in rs.heardRumors
    }
}

// this predicate is the end state predicate that ensures that all nodes have heard the rumor
pred allHeardRumor[r: Rumor] {
    all n: Node | {
        all rs: RumorSpreader | {
            r in n.heardRumors
            r in n.heardRumors'
        }
    }
}

// this predicate models how rumors are spread --- essentially, for a given rumor
// in each round, the rumor spreads exponentially (i.e. 1 -> 2 -> 4 -> 8 -> ...)
// if there are enough nodes remaining to hear the rumor, otherwise, it spreads
// to all remaining nodes
pred distinctSpreadRumor[r: Rumor] {
    let firstRound = {n: Node | r in n.heardRumors} | {
        let secondRound = {n: Node | r in n.heardRumors'} | {
            let ignorant = {n: Node | r not in n.heardRumors} | {
                #(ignorant) > #(firstRound) => {
                    #(firstRound) = #(secondRound - firstRound)
                }
                #(ignorant) <= #(secondRound - firstRound) => {
                    #(ignorant) = #(secondRound - firstRound)
                }
            }
        }
    }
}

// this predicate models the gossip protocol, where for a given rumor,
// all nodes will retain all rumors they have heard in the former state
// and that all rumor spreaders will spread the rumor to at least on other node
pred gossipRumor[r: Rumor] {
    all n: Node | {
        // guard
        n.heardRumors & n.heardRumors' = n.heardRumors

        // action
        all rs: RumorSpreader | {
            r in n.heardRumors => {
                some m: Node | {
                    n != m
                    r in m.heardRumors'
                }
            }
        }
    }
}

// this predicate models what happens when a rumor is not spread in a given round
pred keepRumorUnspread[r: Rumor] {
    all n: Node | {
        r in n.heardRumors <=> r in n.heardRumors'
    }
}

// this predicate models the timeline of running the gossip protocol on one rumor
// it ensures that the rumor starts from the initial state, is eventually spread
// to all nodes, and always gossips in an exponential manner or does nothing in any
// given timestamp
pred spreadOneRumor[r: Rumor] {
    initialRumor[r]
    always {(gossipRumor[r] and distinctSpreadRumor[r]) or allHeardRumor[r] or keepRumorUnspread[r]}
    eventually {allHeardRumor[r]}
}

// traces for our gossip protocol
pred gossipTraces {
    always {wellformed}
    all r: Rumor | {
        spreadOneRumor[r]
    }
} 

run {
    gossipTraces
    #Rumor = 3
} for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor
