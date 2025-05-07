#lang forge/temporal
open "multi_spreader_gossip.frg"

assert multiSpreadGossipTraces is sat for exactly 20 Node, 6 Int, 1 Rumor

assert {wellformed and initialSimple} is sat for exactly 8 Node, 6 Int, 2 RumorSpreader, 6 RumorListener, 2 Rumor
assert {nonConvergence} is sat for exactly 8 Node, 6 Int, 2 RumorSpreader, 6 RumorListener, 2 Rumor
assert {multiSpreadGossipTraces} is sat for exactly 8 Node, 6 Int, 2 RumorSpreader, 6 RumorListener, 2 Rumor
assert {nonConvergence and allHeard} is unsat for exactly 8 Node, 6 Int, 2 RumorSpreader, 6 RumorListener, 2 Rumor

test expect {
    // multiSpreadGossipTraces should always eventually reach allHeard
    convergenceWithDistinctSpread: {
        multiSpreadGossipTraces implies eventually allHeard
    } is checked 
    
    // nonConvergence should never reach allHeard
    nonConvergenceNeverReachesAllHeard: {
        nonConvergence implies always (not allHeard)
    } is checked 
}
