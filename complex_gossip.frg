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

sig RumorSpreader extends Node {
    var baseRumors: set Rumor
}

sig RumorListener extends Node {}

pred wellformed {
    all disj rs1, rs2: RumorSpreader | #{rs1.baseRumors & rs2.baseRumors} = 0
}

pred initialRumor[r: Rumor] {
    all rl: RumorListener | {
        r not in rl.heardRumors
    }
    one rs: RumorSpreader | {
        r in rs.heardRumors
        r in rs.baseRumors
    }
}

pred allHeardRumor[r: Rumor] {
    all n: Node | {
        all rs: RumorSpreader | {
            r in n.heardRumors
            r in n.heardRumors'
        }
    }
}

pred distinctSpreadRumor[r: Rumor] {
    all rs: RumorSpreader | {
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
}

// pred nonDistinctSpread {
//     all rs: RumorSpreader | {
//         let firstRound = {n: Node | {rs.rumor in n.heardRumors}} | {
//             let secondRound = {n: Node | {rs.rumor in n.heardRumors'}} | {
//                 #(secondRound) >= #(firstRound)
//             }
//         }
//     }
// }

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

pred spreadOneRumor[r: Rumor] {
    initialRumor[r]
    always {(gossipRumor[r] and distinctSpreadRumor[r]) or allHeardRumor[r]}
    eventually {allHeardRumor[r]}
}

pred gossipTraces {
    always {wellformed}
    all r: Rumor | {
        eventually {spreadOneRumor[r]}
    }
} 

// pred nonConvergence {
//     always {wellformed}
//     initialSimple
//     always {(gossip and nonDistinctSpread)}
//     always {not allHeard}
// }

run {
    all r: Rumor | {
        always {wellformed}
        always {initialRumor[r]}
    }
} for exactly 20 Node, 5 Rumor, 6 Int 

// run {
//     multiSpreadGossipTraces
// } for exactly 8 Node, 6 Int, 2 RumorSpreader, 6 RumorListener, 2 Rumor
