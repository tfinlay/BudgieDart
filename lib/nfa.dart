import 'package:BudgieDart/common.dart';
import 'package:BudgieDart/util/DefaultMap.dart';

class NFANode implements Node {
  final String name;
  final DefaultMap<String, Set<String>> _connections = DefaultMap(() => {});
  final bool isAccepting;

  NFANode.explicit(this.name, Map<String, Set<String>> connections, this.isAccepting) {
    _connections.addAll(connections);
  }

  void addConnection({required String symbol, required String target}) {
    _connections[symbol].add(symbol);
  }

  Set<String> processString(String symbol) {
    /*
    * 'Processes' the given symbol and returns the ID of the node that the symbol goes to.
    * Returns the empty set if transitions for this symbol have not been defined.
    */
    return _connections[symbol];
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

class NFAGraph extends NodeGraph<Set<String>> {
  final Map<String, NFANode> nodes = {};
  final Set<String> alphabet;
  final String startNodeName;

  NFAGraph({required this.alphabet, required this.startNodeName});

  @override
  NFANode createNode({required String name, bool accepting = false, Map<String, Set<String>> connections = const {}}) {
    if (nodes.containsKey(name)) {
      throw ArgumentError.value(name, 'name', 'a node with that name already exists');
    }

    final newNode = NFANode.explicit(name, connections, accepting);
    nodes[name] = newNode;

    return newNode;
  }

  void validateSelf() {
    /*
    * Verifies the following NFA assumptions:
    *   - that every outgoing edge goes to a real node name.
    *   - that the startNode exists.
    * Throws StateError if these assumptions are not found to hold.
    */
    if (!nodes.containsKey(startNodeName)) {
      throw StateError('Failed to find a node with the same name as startNode');
    }

    final nodeNames = Set.of(nodes.keys);

    for (final node in nodes.values) {
      node.verifyOutgoingNodes(nodeNames);
    }
  }

  void _validateSelfAndString(List<String> string) {
    validateSelf();
    if (!isStringValid(string)) {
      throw ArgumentError.value(string, 'string', 'contains symbols that are not in the defined alphabet.');
    }
  }

  Iterable<Set<NFANode>> processString(List<String> string, {bool performValidation = true}) sync* {
    if (performValidation) {
      _validateSelfAndString(string);
    }

    var currentNodes = <NFANode>{nodes[startNodeName]!,};
    yield currentNodes;

    for (final symbol in string) {
      if (currentNodes.isEmpty) {
        break;
      }

      final newNodes = <NFANode>{};

      for (final node in currentNodes) {
        newNodes.addAll(node.processString(symbol).map((nodeName) => nodes[nodeName]!));
      }

      yield newNodes;

      currentNodes = newNodes;
    }
  }

  @override
  bool acceptsString(List<String> string, {bool performValidation = true}) {
    // Returns true if any of the last nodes reached by this string are accepting.
    return processString(string, performValidation: performValidation).last.any((node) => node.isAccepting);
  }
}