import 'package:BudgieDart/dfa.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  test('validateSelf', () {
    final g1 = generateRandomDfa(32, {'0', '1'});
    expect(() => g1.validateSelf(), returnsNormally);

    final g2 = DFAGraph(alphabet: {'0'}, startNodeName: 'q0');
    expect(() => g2.validateSelf(), throwsStateError);

    final q3 = DFAGraph(alphabet: {}, startNodeName: 'q0');
    expect(() => q3.validateSelf(), throwsStateError);

    final n1 = q3.createNode(name: 'q0');
    expect(() => q3.validateSelf(), returnsNormally);

    n1.addConnection(symbol: 'a', target: 'q0');
    expect(() => q3.validateSelf(), throwsStateError);
  });
}
