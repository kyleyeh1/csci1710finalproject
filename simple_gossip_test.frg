#lang forge/temporal

open "simple_gossip.frg"

assert simpleGossipTraces is sat for exactly 20 Node, 6 Int, 1 Rumor
assert nonConvergence is sat for exactly 20 Node, 6 Int, 1 Rumor
assert gossip is necessary for simpleGossipTraces for exactly 20 Node, 6 Int, 1 Rumor

assert {#RumorSpreader.heardRumors = 0 and wellformed} is unsat for exactly 20 Node, 6 Int, 1 Rumor
assert {nonConvergence and allHeard} is unsat for exactly 20 Node, 6 Int, 1 Rumor
assert {gossip and distinctSpread} is sat for exactly 20 Node, 6 Int, 1 Rumor
assert {gossip and nonDistinctSpread} is sat for exactly 20 Node, 6 Int, 1 Rumor

assert {all r: Rumor | no rs: RumorSpreader | rs.rumor = r} is unsat for exactly 20 Node, 6 Int, 1 Rumor

test expect {
    // simpleGossipTraces should always eventually reach allHeard
    convergenceWithDistinctSpread: {
        simpleGossipTraces implies eventually allHeard
    } is checked 
    
    // nonConvergence should never reach allHeard
    nonConvergenceNeverReachesAllHeard: {
        nonConvergence implies always (not allHeard)
    } is checked 
}
