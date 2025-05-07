#lang forge/temporal

open "complex_gossip.frg"

assert gossipTraces is sat for exactly 20 Node, 6 Int, 1 Rumor

assert {
  gossipTraces implies eventually {all n: Node, r: Rumor | r in n.heardRumors}
} is sat for exactly 10 Node, 6 Int, 2 RumorSpreader, 8 RumorListener, 3 Rumor



