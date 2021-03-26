import 'package:BudgieDart/BudgieDart.dart' as Budgie;

void main(List<String> arguments) {
  final graph = Budgie.DFAGraph(
    alphabet: {'0', '1'},
    startNodeName: 'q0'
  );

  graph.createNode(
    name: 'q0',
    accepting: true,
    connections: {
      '0': 'q0',
      '1': 'q0'
    }
  );

  graph.validateSelf();

  graph.acceptsString([]);
}
