import 'package:BudgieDart/dfa.dart';
import '../common.dart';

DFAGraph generateRandomDfa(int size, Set<String> alphabet) {
  assert(size > 0);
  final graph = DFAGraph(alphabet: alphabet, startNodeName: 'q0');

  for (var i=0; i < size; i++) {
    graph.createNode(name: 'q$i', connections: {
      for (final symbol in alphabet)
        symbol: 'q${randomIndex(size)}'
    });
  }

  return graph;
}