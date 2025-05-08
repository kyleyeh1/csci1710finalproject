#lang forge/temporal

open "complex_gossip.frg"

// idk the syntax for testing the predicates that take a rumor as an argument
assert gossipTraces is sat for exactly 20 Node, 6 Int, 1 Rumor

assert {
  gossipTraces implies eventually {all n: Node, r: Rumor | r in n.heardRumors}
} is sat for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor

assert {some r: Rumor  | gossipRumor[r]} is sat for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor
assert {some r: Rumor  | spreadOneRumor[r]} is sat for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor
assert {some r: Rumor  | allHeardRumor[r]} is sat for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor
assert {some r: Rumor  | distinctSpreadRumor[r]} is sat for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor

test expect {
    // gossipTraces should always eventually reach allHeard
    convergenceWithDistinctSpread: {
        gossipTraces implies eventually (all r: Rumor | allHeardRumor[r])
    } is checked 
}
