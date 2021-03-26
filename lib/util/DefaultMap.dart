import 'dart:collection';

class DefaultMap<K, V> with MapMixin<K, V> implements Map<K, V> {
  final Map<K, V> _internalMap = {};
  final V Function() _defaultBuilder;

  DefaultMap(this._defaultBuilder);

  @override
  V operator [](Object? key) {
    if (!(key is K)) {
      throw ArgumentError.value(key, 'key', "Is of the incorrect type.");
    }

    if (!_internalMap.containsKey(key)) {
      _internalMap[key] = _defaultBuilder();
    }

    return _internalMap[key]!;
  }

  @override
  void operator []=(K key, V value) {
    _internalMap[key] = value;
  }

  @override
  void clear() {
    _internalMap.clear();
  }

  @override
  // TODO: implement keys
  Iterable<K> get keys => _internalMap.keys;

  @override
  V? remove(Object? key) {
    _internalMap.remove(key);
  }

}