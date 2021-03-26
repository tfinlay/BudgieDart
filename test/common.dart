import 'dart:math';

final Random generator = Random(123);

int randomIndex(int size) {
  return generator.nextInt(size);
}