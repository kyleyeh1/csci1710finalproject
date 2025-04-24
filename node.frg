#lang forge/temporal

option max_tracelength 14

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
                #(ignorant) > #(firstRound) => {
                    #(firstRound) = #(secondRound - firstRound)
                }
                #{ignorant} <= #{secondRound - firstRound} => {
                    // #{ignorant} = #{secondRound - firstRound}
                }
            }
            // #{firstRound} = min[#{secondRound - firstRound}, #{n: Node | {RumorSpreader.rumor not in n.heardRumors}}]
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
                RumorSpreader.rumor not in m.heardRumors
            }
        }
    }
}


run {
    always {wellformed}
    initialSimple
    always {(gossip and distinctSpread) or allHeard}
} for exactly 10 Node, 5 Int
