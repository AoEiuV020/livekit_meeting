class ServerToken {
  String serverUrl;
  String token;

  ServerToken({required this.serverUrl, required this.token});

  // 从 Map 转为 对象
  factory ServerToken.fromJson(Map<String, dynamic> json) => ServerToken(
    serverUrl: json['serverUrl'] as String,
    token: json['token'] as String,
  );
}