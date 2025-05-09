#lang forge/temporal

open "turbo_gossip.frg"

pred gossipTracesSufficient {
  some r: Rumor | {always{(gossipRumor[r] and distinctSpreadRumor[r]) or allHeardRumor[r] or keepRumorUnspread[r]}}
}

assert gossipTraces is sat for exactly 20 Node, 6 Int, 1 Rumor
assert wellformed is necessary for gossipTraces for exactly 20 Node, 6 Int, 1 Rumor
assert gossipTraces is sufficient for wellformed for exactly 20 Node, 6 Int, 1 Rumor

assert {
  gossipTraces implies eventually {all n: Node, r: Rumor | r in n.heardRumors}
} is sat for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor

assert {some r: Rumor | initialRumor[r]} is sat for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor
assert {some r: Rumor  | gossipRumor[r]} is sat for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor
assert {some r: Rumor  | spreadOneRumor[r]} is sat for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor
assert {some r: Rumor  | allHeardRumor[r]} is sat for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor
assert {some r: Rumor  | distinctSpreadRumor[r]} is sat for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor
assert {some r: Rumor  | keepRumorUnspread[r]} is sat for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor
assert wellformed and {some r: Rumor  | keepRumorUnspread[r] and distinctSpreadRumor[r] and initialRumor[r]} is unsat for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor
