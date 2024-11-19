import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('jsonEncode empty', () async {
    print(json.runtimeType);
    expect(jsonDecode('null'), isNull);
    expect(jsonDecode('{}'), isA<Map>());
    expect(
      () => jsonDecode(''),
      throwsA(isA<FormatException>()),
    );
  });
}
