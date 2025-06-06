#lang forge/temporal

/*
This file models that a simple gossip protocol with only one rumor spreader spreading one rumor 
at once. Rumors spread at an exponential rate. Also models that non-convergence can occur.
*/

option max_tracelength 14
option min_tracelength 5
option no_overflow true
option run_sterling "simple_gossip_vis.js"

abstract sig Node {
    var heardRumors: set Rumor
}

sig Rumor {}

one sig RumorSpreader extends Node {
    rumor: one Rumor
}

sig RumorListener extends Node {}

pred wellformed {
    RumorSpreader.rumor in RumorSpreader.heardRumors
}

pred initialSimple {
    all rl: RumorListener | {
        #{rl.heardRumors} = 0
    }
}

pred allHeard {
    all n: Node | {
        RumorSpreader.rumor in n.heardRumors
        RumorSpreader.rumor in n.heardRumors'
    }
}

pred distinctSpread {
    let firstRound = {n: Node | {RumorSpreader.rumor in n.heardRumors}} | {
        let secondRound = {n: Node | {RumorSpreader.rumor in n.heardRumors'}} | {
            let ignorant = {n : Node | {RumorSpreader.rumor not in n.heardRumors}} | {
                #(ignorant) > #(firstRound) => { // more ignorant nodes than spreaders
                    #(firstRound) = #(secondRound - firstRound)
                }
                #{ignorant} <= #{secondRound - firstRound} => { // ignorant nodes less than or equal to spreaders
                    #{ignorant} = #{secondRound - firstRound}
                }
            }
        }
    }
}

pred nonDistinctSpread {
    let firstRound = {n: Node | {RumorSpreader.rumor in n.heardRumors}} | {
        let secondRound = {n: Node | {RumorSpreader.rumor in n.heardRumors'}} | {
            #(secondRound) >= #(firstRound)
        }
    }
}

pred gossip {
    all n: Node | {
        // guard
        n.heardRumors & n.heardRumors' = n.heardRumors

        // action
        RumorSpreader.rumor in n.heardRumors => {
            some m: Node | {
                n != m
                RumorSpreader.rumor in m.heardRumors'
            }
        }
    }
}

// traces for our gossip protocol
pred simpleGossipTraces {
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
    simpleGossipTraces
} for exactly 20 Node, 6 Int, 1 Rumor

run {
    nonConvergence
} for exactly 20 Node, 6 Int, 1 Rumor
