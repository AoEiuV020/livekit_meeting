import 'package:flutter_test/flutter_test.dart';

void main() {
  test('href parse', () async {
    const href = 'https://www.baidu.com/?a=s&d&f=g';
    final uri = Uri.parse(href);
    final queryParams = uri.queryParameters;
    print(queryParams);
    assert(queryParams['a'] == 's');
    assert(queryParams['d'] == '');
    assert(queryParams['f'] == 'g');
  });
}
