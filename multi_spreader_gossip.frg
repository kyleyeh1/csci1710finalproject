#lang forge/temporal

/*
This file models a gossip protocol where multiple spreaders can spread one distinct rumor at each
time stamp. Rumors spread at an exponential rate. Also models that non-convergence can occur.
*/

option max_tracelength 14
option min_tracelength 5
option no_overflow true
option run_sterling "simple_gossip_vis.js"

abstract sig Node {
    var heardRumors: set Rumor
}

sig Rumor {}

sig RumorSpreader extends Node {
    rumor: one Rumor
}

sig RumorListener extends Node {}

pred wellformed {
    all disj rs1, rs2: RumorSpreader | rs1.rumor != rs2.rumor
    all r: Rumor | one rs: RumorSpreader | rs.rumor = r
}

pred initialSimple {
    all rl: RumorListener | {
        #{rl.heardRumors} = 0
    }
    all rs: RumorSpreader | {
        rs.rumor in rs.heardRumors
        #{rs.heardRumors} = 1
    }
}

pred allHeard {
    all n: Node | {
        all rs: RumorSpreader | {
            rs.rumor in n.heardRumors
            rs.rumor in n.heardRumors'
        }
    }
}

pred distinctSpread {
    all rs: RumorSpreader | {
        let firstRound = {n: Node | rs.rumor in n.heardRumors} | {
            let secondRound = {n: Node | rs.rumor in n.heardRumors'} | {
                let ignorant = {n: Node | rs.rumor not in n.heardRumors} | {
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
}

pred nonDistinctSpread {
    all rs: RumorSpreader | {
        let firstRound = {n: Node | {rs.rumor in n.heardRumors}} | {
            let secondRound = {n: Node | {rs.rumor in n.heardRumors'}} | {
                #(secondRound) >= #(firstRound)
            }
        }
    }
}

pred gossip {
    all n: Node | {
        // guard
        n.heardRumors & n.heardRumors' = n.heardRumors

        // action
        all rs: RumorSpreader | {
            rs.rumor in n.heardRumors => {
                some m: Node | {
                    n != m
                    rs.rumor in m.heardRumors'
                }
            }
        }
    }
}

// traces for our gossip protocol
pred multiSpreadGossipTraces {
    always {wellformed}
    initialSimple
    always {(gossip and distinctSpread) or allHeard}
    eventually {allHeard}
}

pred nonConvergence {
    always {wellformed}
    initialSimple
    always {(gossip and nonDistinctSpread)}
    always {not allHeard}
}

run {
    multiSpreadGossipTraces
} for exactly 20 Node, 6 Int, 2 RumorSpreader, 18 RumorListener, 2 Rumor

run {
    nonConvergence
} for exactly 20 Node, 6 Int, 2 RumorSpreader, 18 RumorListener, 2 Rumor
