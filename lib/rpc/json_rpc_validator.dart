import 'dart:convert';

class JsonRpcValidator {
  static const String jsonRpc = '2.0';

  static bool isJsonRpcMessage(String message) {
    try {
      final payload = json.decode(message);
      return isValidJsonRpcPayload(payload);
    } catch (e) {
      return false;
    }
  }

  /// 判断已解析的payload是否为合法的JSON-RPC消息
  static bool isValidJsonRpcPayload(dynamic payload) {
    return isJsonRpcRequest(payload) ||
        isJsonRpcResponse(payload) ||
        isJsonRpcRequests(payload) ||
        isJsonRpcResponses(payload);
  }

  static bool isJsonRpcRequest(dynamic payload) {
    return payload is Map<String, dynamic> &&
        payload['jsonrpc'] == jsonRpc &&
        payload['method'] != null &&
        !payload.containsKey('result') &&
        !payload.containsKey('error');
  }

  static bool isJsonRpcRequests(dynamic payload) {
    return payload is List && payload.every(isJsonRpcRequest);
  }

  static bool isJsonRpcResponse(dynamic payload) {
    return payload is Map<String, dynamic> &&
        payload['jsonrpc'] == jsonRpc &&
        payload['id'] != null &&
        (payload.containsKey('result') || payload.containsKey('error'));
  }

  static bool isJsonRpcResponses(dynamic payload) {
    return payload is List && payload.every(isJsonRpcResponse);
  }
}
