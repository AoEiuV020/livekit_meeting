import '../exception.dart';

/// JSON-RPC 2.0 预定义错误码
class RpcErrorCode {
  static const int parseError = -32700;
  static const int invalidRequest = -32600;
  static const int methodNotFound = -32601;
  static const int invalidParams = -32602;
  static const int internalError = -32603;

  // 服务端错误码范围
  static const int serverErrorMin = -32099;
  static const int serverErrorMax = -32000;
}

/// RPC 基础异常类
class MeetingRpcException extends MeetingException {
  final int code;
  final Object? data;

  const MeetingRpcException(this.code, String message, [this.data])
      : super(message);
}

/// 解析错误
class ParseError extends MeetingRpcException {
  ParseError([String message = 'Parse error', Object? data])
      : super(RpcErrorCode.parseError, message, data);
}

/// 无效请求
class InvalidRequest extends MeetingRpcException {
  InvalidRequest([String message = 'Invalid Request', Object? data])
      : super(RpcErrorCode.invalidRequest, message, data);
}

/// 方法未找到
class MethodNotFound extends MeetingRpcException {
  MethodNotFound([String message = 'Method not found', Object? data])
      : super(RpcErrorCode.methodNotFound, message, data);
}

/// 无效参数
class InvalidParams extends MeetingRpcException {
  InvalidParams([String message = 'Invalid params', Object? data])
      : super(RpcErrorCode.invalidParams, message, data);
}

/// 内部错误
class InternalError extends MeetingRpcException {
  InternalError([String message = 'Internal error', Object? data])
      : super(RpcErrorCode.internalError, message, data);
}

/// 服务器错误
class ServerError extends MeetingRpcException {
  ServerError(
    super.code, [
    super.message = 'Server error',
    super.data,
  ]) : assert(
          code >= RpcErrorCode.serverErrorMin &&
              code <= RpcErrorCode.serverErrorMax,
          'Server error code must be between ${RpcErrorCode.serverErrorMin} and ${RpcErrorCode.serverErrorMax}',
        );
}
