#lang forge/temporal

open "simple_gossip.frg"

assert simpleGossipTraces is sat for exactly 20 Node, 6 Int, 1 Rumor
assert nonConvergence is sat for exactly 20 Node, 6 Int, 1 Rumor
assert gossip is necessary for simpleGossipTraces for exactly 20 Node, 6 Int, 1 Rumor

assert {#RumorSpreader.heardRumors = 0 and wellformed} is unsat for exactly 20 Node, 6 Int, 1 Rumor

assert {all r: Rumor | no rs: RumorSpreader | rs.rumor = r} is unsat for exactly 20 Node, 6 Int, 1 Rumor

