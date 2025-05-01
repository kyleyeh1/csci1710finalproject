#lang forge/temporal

option max_tracelength 14
option min_tracelength 5
option no_overflow true
option run_sterling "simple_gossip_vis.js"

one sig System {}

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
                // firstRound in secondRound
                // #(ignorant) > #(firstround)
                #(ignorant) > #(firstRound) => { // More Ignorant Nodes Than Spreaders
                    #(firstRound) = #(secondRound - firstRound)
                }
                #{ignorant} <= #{secondRound - firstRound} => { // Ignorant Nodes Less Than or Equal to Spreaders
                    #{ignorant} = #{secondRound - firstRound}
                }
            }
            // #{firstRound} = min[#{secondRound - firstRound}, #{n: Node | {RumorSpreader.rumor not in n.heardRumors}}]
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
                // RumorSpreader.rumor not in m.heardRumors
            }
        }
    }
}

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
