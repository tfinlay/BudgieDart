abstract class Node {
  String get name;
  bool get isAccepting;

  void addConnection({required String symbol, required String target});
}

abstract class NodeGraph<T> {
  Map<String, Node> get nodes;
  Set<String> get alphabet;
  String get startNodeName;

  Node createNode({required String name, bool accepting = false, Map<String, T> connections = const {}});

  bool acceptsString(List<String> string, {bool performValidation = true});

  bool isStringValid(List<String> string) {
    /*
    * Returns whether or not the given string is within the alphabet
    */
    return alphabet.containsAll(string);
  }
}