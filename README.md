# csci1710finalproject

## README

### Introduction

Our model explores the dynamics of gossip protocols, focusing on how rumors spread through a network of nodes. We structured our model around several key components: Nodes (which can be either RumorSpreaders or RumorListeners), Rumors, and the temporal spread of information.

Gossip protocols are important because they enable efficient information spread in distributed systems. They are used in various applications such as service discovery networks, peer-to-peer networks, and system health checks. Some common users of gossip protocols include GitHub, HashiCorp Consul, AWS DynamoDB, and even Bitcoin.

### Model Structure and Representation Tradeoffs

We developed multiple versions of the gossip protocol with increasing complexity:

1. **Simple Gossip Model**: A basic model with one rumor spreader and one rumor
2. **Multi-Spreader Model**: Multiple spreaders each with their own distinct rumor
3. **Complex Gossip Model**: Multiple spreaders with multiple rumors spreading at different times
4. **Turbo Gossip Model**: The most complex version where multiple spreaders can spread multiple rumors simultaneously with varying spread rates, starting at varying times

The key tradeoff we made was between model complexity and verification capabilities. Initially, we tried modeling the gossip protocol with specific network topologies (like rings or trees), but this made verification difficult. Instead, we abstracted away the network topology and focused on the exponential spread pattern, which allowed us to verify important properties while keeping the model manageable.

We also experimented with different spread patterns before settling on the exponential spread model (where rumors double each round until all nodes are informed). We have put in place some half-baked predicates that don't enforce this policy, but this leads to very long traces. We initially tried a linear pattern as well, but that made verification too complicated in the later protocols.

Through our model exploration, we decided that the best way to explore how different ordering protocols interact with the gossip model was to ensure that our gossip protocol automatically follow FIFO (First-in-first-out) and causal ordering. In industry, adherence to these ordering protocols are generally of high importance in order to ensure agreement among nodes, which means that having the model automatically implement these protocols mostly aligns with industry performance specifications.

### Scope and Model Limitations

Our model makes several assumptions to keep the scope manageable:

1. **Persistent Knowledge**: Once a node hears a rumor, it never forgets it
2. **Exponential Spread**: Rumors spread in a doubling pattern (1→2→4→8→...)
3. **Distinct Rumors**: Each RumorSpreader has its own set of base rumors that don't overlap with other spreaders
4. **No Network Topology**: We abstract away specific network connections, i.e., every node is connected to each other, and the network is fully connected
5. **No Message Loss**: Communication is reliable with no dropped messages

The main limitations include:

- No modeling of network failures or node crashes
- No consideration of message delays or asynchronous communication
- No modeling of malicious nodes that might corrupt rumors/consideration for Byzantine behaviors
- Fixed rate of information spread, rather than a probabilistic one

### Evolution of Goals

Our initial proposal focused on modeling basic gossip protocols, but as we progressed, we realized we could model more complex variants. We expanded our goals to include:

1. Verifying convergence properties (that all nodes eventually hear all rumors)
2. Modeling scenarios where convergence fails (in the simple and complex cases)
3. Supporting multiple simultaneous rumors with different spread patterns

One aspect we found more realistic than anticipated was modeling the exponential spread pattern, which we initially thought would be challenging but turned out to be quite elegant in Forge. However, we had to simplify our initial goal of modeling specific network topologies as it made the model too complex.

### Understanding Model Instances and Visualization

An instance of our model represents a temporal trace of rumor propagation through a network. The visualization shows:

- **Nodes**: Represented as circles, with RumorSpreaders and RumorListeners distinguished
- **Rumors**: Represented as distinct colors/patterns
- **Time**: The progression through discrete time steps as rumors spread
- **Heard Rumors**: The set of rumors each node has heard at each time step

The visualization demonstrates how rumors spread exponentially from their source nodes until they reach all nodes in the network. It also shows cases of non-convergence where some rumors never reach all nodes.

Our tests verify important properties like:

- Convergence with distinct spread (all nodes eventually hear all rumors)
- Non-convergence scenarios never reach the state where all nodes hear all rumors
- The wellformedness of our model (each rumor has exactly one spreader)

Through this model, we've been able to formally verify the fundamental properties of gossip protocols and explore the conditions under which they succeed or fail to achieve full information dissemination.


