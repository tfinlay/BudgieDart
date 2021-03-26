/*
* DFA implementation
*/
import 'common.dart';

class DFANode implements Node {
  final String name;
  final Map<String, String> _connections = {};
  final Set<String> _connectionSymbols = {};
  final bool isAccepting;

  DFANode.explicit(this.name, Map<String, String> connections, this.isAccepting) {
    _connections.addAll(connections);
    _connectionSymbols.addAll(connections.keys);
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

  void verifyOutgoingNodes(Set<String> extantNodes) {
    /*
    * Checks that all of the nodes specified in the outgoing edges exist (are in extantNodes).
    */
    if (!extantNodes.containsAll(_connections.values)) {
      throw StateError('DFA node refers to another node that does not exist.');
    }
  }
}


class DFAGraph extends NodeGraph<String> {
  final Map<String, DFANode> nodes = {};
  final Set<String> alphabet;
  final String startNodeName;

  DFAGraph({required this.alphabet, required this.startNodeName});

  @override
  DFANode createNode({required String name, bool accepting = false, Map<String, String> connections = const {}}) {
    if (nodes.containsKey(name)) {
      throw ArgumentError.value(name, 'name', 'a node with that name already exists');
    }

    final newNode = DFANode.explicit(name, connections, accepting);
    nodes[name] = newNode;

    return newNode;
  }

  void validateSelf() {
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
      node.verifyOutgoingNodes(nodeNames);
    }
  }

  void _validateSelfAndString(List<String> string) {
    validateSelf();
    if (!isStringValid(string)) {
      throw ArgumentError.value(string, 'string', 'contains symbols that are not in the defined alphabet.');
    }
  }

  Iterable<DFANode> processString(List<String> string, {bool performValidation = true}) sync* {
    /*
    * Verifies and processes the string of symbols, yielding the current DFA after each symbol.
    */
    if (performValidation) {
      _validateSelfAndString(string);
    }

    var currentNode = nodes[startNodeName]!;
    yield currentNode;

    for (final symbol in string) {
      final nextNodeName = currentNode.processSymbol(symbol);
      currentNode = nodes[nextNodeName]!;
      yield currentNode;
    }
  }

  bool acceptsString(List<String> string, {bool performValidation = true}) {
    return processString(string, performValidation: performValidation).last.isAccepting;
  }
}