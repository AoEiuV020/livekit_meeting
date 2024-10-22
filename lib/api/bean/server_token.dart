import 'dart:convert';

class ServerToken {
  String serverUrl;
  String token;

  ServerToken({required this.serverUrl, required this.token});

  Map<String, dynamic> toMap() {
    return {
      'serverUrl': serverUrl,
      'token': token,
    };
  }

  factory ServerToken.fromMap(Map<String, dynamic> map) {
    return ServerToken(
      serverUrl: map['serverUrl'] ?? '',
      token: map['token'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ServerToken.fromJson(String source) =>
      ServerToken.fromMap(json.decode(source));
}
