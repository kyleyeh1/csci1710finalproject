const nodes = Node.tuples().map(tuple => tuple.atoms()[0]);

nodes.forEach(node => {
    // find rumors heard, use .length and [] operator for data
    let heard = node.join(heardRumors).tuples().map(t => t.atoms()[0].id());
    let nextHeard = node.join(heardRumors).tuples().map(t => t.atoms()[0].id());
    console.log(node.id());
    console.log(heard);
});
