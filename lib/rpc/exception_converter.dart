import 'package:flutter/services.dart'
    show MissingPluginException, PlatformException;

import 'package:json_rpc_2/json_rpc_2.dart' show RpcException;

import 'exceptions.dart';

/// RPC 异常转换工具类
class RpcExceptionConverter {
  /// 检查字符串是否可以转换为整数
  static bool _isNumeric(String? str) {
    if (str == null) return false;
    return int.tryParse(str) != null;
  }

  /// 处理错误码并转换为对应的异常
  static MeetingRpcException _handleErrorCode(int code, String? message,
      [Object? data]) {
    switch (code) {
      case RpcErrorCode.parseError:
        return ParseError(message ?? 'Parse error', data);
      case RpcErrorCode.invalidRequest:
        return InvalidRequest(message ?? 'Invalid Request', data);
      case RpcErrorCode.methodNotFound:
        return MethodNotFound(message ?? 'Method not found', data);
      case RpcErrorCode.invalidParams:
        return InvalidParams(message ?? 'Invalid params', data);
      case RpcErrorCode.internalError:
        return InternalError(message ?? 'Internal error', data);
      default:
        if (code >= RpcErrorCode.serverErrorMin &&
            code <= RpcErrorCode.serverErrorMax) {
          return ServerError(code, message ?? 'Server error', data);
        }
        return MeetingRpcException(code, message ?? 'Unknown error', data);
    }
  }

  /// 转换 json_rpc_2 包的异常为统一的异常类型
  static MeetingRpcException convertJsonRpcException(Object error) {
    if (error is RpcException) {
      return _handleErrorCode(error.code, error.message, error.data);
    }
    return InternalError(error.toString());
  }

  /// 转换平台通道异常为统一的异常类型
  static MeetingRpcException convertPlatformException(Object error) {
    // 如果已经是 MeetingRpcException 类型，则直接返回
    if (error is MeetingRpcException) {
      return error;
    }

    if (error is PlatformException) {
      // 尝试解析数字错误码
      final code = int.tryParse(error.code);
      if (code != null) {
        return _handleErrorCode(code, error.message, error.details);
      }

      // 处理特定的字符串错误码
      switch (error.code) {
        case 'notImplemented':
          // 这case可能没有实际用到，
          return MethodNotFound(
              error.message ?? 'Method not found', error.details);
        default:
          return ServerError(
            RpcErrorCode.serverErrorMax,
            error.message ?? 'Unknown error ${error.code}',
            error.details,
          );
      }
    } else if (error is ArgumentError) {
      return InvalidParams(error.message ?? 'Invalid params');
    } else if (error is RpcException) {
      return convertJsonRpcException(error);
    } else if (error is UnimplementedError) {
      return MethodNotFound(error.message ?? 'Method not found');
    } else if (error is MissingPluginException) {
      return MethodNotFound(error.message ?? 'Method not found');
    }

    return InternalError(error.toString());
  }
}
