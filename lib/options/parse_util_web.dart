import 'dart:html';

Future<List<String>> prepareArgs(List<String> args) async {
  String href = window.location.href;
  // 使用 Uri 解析 URL
  Uri uri = Uri.parse(href); // 获取查询参数
  Map<String, String> queryParams = uri.queryParameters;
  // 将 Map 转换为 List<String>，每个 key 和 value 单独作为一个元素
  args = queryParams.entries
      .expand((entry) => ['--${entry.key}', entry.value])
      .toList();
  return args;
}
