import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

@immutable
class Example {
  final List<String> values;

  const Example(this.values);

  String? findFirst(String prefix) {
    return values.firstWhereOrNull((v) => v.startsWith(prefix));
  }

  static ArgParser buildParser() {
    return ArgParser()..addFlag('verbose', abbr: 'v', negatable: false);
  }
}
