import 'package:flutter_cube/flutter_cube.dart' as cube;

class Atom {
  final cube.Vector3 position;
  final String element;

  Atom({
    required this.position,
    required this.element,
  });
}
