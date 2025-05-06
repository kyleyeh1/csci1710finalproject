#lang forge/temporal

/*
allows for the spread of multiple rumors at separate times from multiple spreaders
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

pred wellformed {
    all disj rs1, rs2: RumorSpreader | #{{rs1.baseRumors} & {rs2.baseRumors}} = 0
    all rs: RumorSpreader { 
        rs.baseRumors = rs.baseRumors'
    }
}

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

pred keepRumorUnspread[r: Rumor] {
    all n: Node | {
        r in n.heardRumors <=> r in n.heardRumors'
    }
}

pred spreadOneRumor[r: Rumor] {
    initialRumor[r]
    always {(gossipRumor[r] and distinctSpreadRumor[r]) or allHeardRumor[r] or keepRumorUnspread[r]}
    // always {allHeardRumor[r] or keepRumorUnspread[r]}
    eventually {allHeardRumor[r]}
}

pred gossipTraces {
    always {wellformed}
    all r: Rumor | {
        spreadOneRumor[r]
    }
} 

run {
    gossipTraces
    #Rumor = 3 // apparently this is the only way it works lmao
} for exactly 10 Node, 7 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor
