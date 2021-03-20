const DEFAULT_ALPHABET = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']

class DFANode {
  final String name;
  final Map<String, String> _connections = {};
  final Set<String> _connectionSymbols = {};
  final bool accepting;

  DFANode.explicit(String this.name, Map<String, String> connections, this.accepting) {
    _connections.addAll(connections);
  }

  void addConnection({required String symbol, required String target}) {
    if (_connectionSymbols.contains(symbol)) {
      throw ArgumentError.value(symbol, "symbol", "already exists in this node");
    }

    _connections[symbol] = target;
    _connectionSymbols.add(symbol);
  }

  String processSymbol(String symbol) {
    /*
    * 'Processes' the given symbol and returns the ID of the node that the symbol goes to.
    * Throws an ArgumentError if the symbol's target node has not been defined.
    */

    final toNodeName = _connections[symbol];

    if (toNodeName == null) {
      throw ArgumentError.value(symbol, "symbol", "Is not defined on this node.");
    }

    return toNodeName;
  }
  
  void verifyAlphabet(Set<String> alphabet) {
    if (_connectionSymbols.difference(alphabet).isNotEmpty || alphabet.intersection(_connectionSymbols).length != alphabet.length) {
      throw StateError('DFA Alphabet and connectionSymbols are different. They must be identical.');
    }
  }

  void verifyOutoingNodes(Set<String> extantNodes) {
    /*
    * Checks that all of the nodes specified in the outgoing edges exist (are in extantNodes).
    */
    if (!extantNodes.containsAll(_connections.values)) {
      throw StateError('DFA node refers to another node that does not exist.');
    }
  }
}


class DFAGraph {
  final Map<String, DFANode> nodes = Map();
  final Set<String> alphabet;
  final String startNodeName;

  DFAGraph({required this.alphabet, required this.startNodeName});
  
  DFANode createNode({required String name, bool accepting = false, Map<String, String> connections = const {}}) {
    if (nodes.containsKey(name)) {
      throw ArgumentError.value(name, 'name', 'a node with that name already exists');
    }
    
    final newNode = DFANode.explicit(name, connections, accepting);
    nodes[name] = newNode;

    return newNode;
  }
  
  void verifySelf() {
    /*
    * Verifies the following DFA assumptions:
    *   - that every node has every member of the alphabet on an outgoing edge.
    *   - that every outgoing edge goes to a real node name.
    *   - that the startNode exists.
    * Throws StateError if these assumptions are not found to hold.
    */
    if (!nodes.containsKey(startNodeName)) {
      throw StateError('Failed to find a node with the same name as startNode');
    }

    final nodeNames = Set.of(nodes.keys);

    for (final node in nodes.values) {
      node.verifyAlphabet(alphabet);
      node.verifyOutoingNodes(nodeNames);
    }
  }

  bool isStringValid(List<String> string) {
    /*
    * Returns whether or not the given string is within the alphabet
    */
    return alphabet.containsAll(string);
  }

  void _verifySelfAndString(List<String> string) {
    verifySelf();
    if (!isStringValid(string)) {
      throw ArgumentError.value(string, 'string', 'contains symbols that are not in the defined alphabet.');
    }
  }

  Iterable<DFANode> processString(List<String> string, {bool performVerification = true}) sync* {
    /*
    * Verifies and processes the string of symbols, yielding the current DFA after each symbol.
    */
    if (performVerification) {
      _verifySelfAndString(string);
    }

    var currentNode = nodes[startNodeName]!;
    yield currentNode;

    for (final symbol in string) {
      final nextNodeName = currentNode.processSymbol(symbol);
      currentNode = nodes[nextNodeName]!;
      yield currentNode;
    }
  }

  bool acceptsString(List<String> string, {bool performVerification = true}) {

  }
}