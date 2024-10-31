import 'package:dio/dio.dart';

import 'bean/server_token.dart';

class LivekitService {
  static const pathPrefix = 'api';
  String _baseUrl = '';
  String get baseUrl => _baseUrl;
  set baseUrl(String baseUrl) {
    _baseUrl = baseUrl;
    if (baseUrl.isEmpty) return;
    _dio = Dio(BaseOptions(
      baseUrl: '$baseUrl/$pathPrefix',
    ));
  }

  Dio? _dio;
  Dio get dio => _dio!;

  LivekitService(String baseUrl) {
    baseUrl = baseUrl;
  }
  Future<ServerToken> getToken(String roomName, String participantName) async {
    final response = await getRequest('/connection-details',
        {'roomName': roomName, 'participantName': participantName});
    return ServerToken(
        serverUrl: response['serverUrl'], token: response['participantToken']);
  }

  /// 使用dio请求post接口，返回json,
  Future<Map<String, dynamic>> postRequest(
      String path, Map<String, dynamic> body) {
    return dio.post(path, data: body).then((value) => value.data!);
  }

  /// 使用dio请求get接口，返回json,
  Future<Map<String, dynamic>> getRequest(
      String path, Map<String, dynamic>? query) async {
    return dio.get(path, queryParameters: query).then((value) => value.data!);
  }
}
