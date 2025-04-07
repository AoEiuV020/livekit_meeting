import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// 特殊的WebSocket服务器，
/// 仅用于处理本机单个客户端的连接和消息，
/// 仅能启动一次，启动后保存端口到指定文件等待连接，
/// 暴露channel用于封装成jsonRpc，
class WebSocketServer {
  final logger = Logger('WebSocketServer');
  static final WebSocketServer _instance = WebSocketServer._internal();
  static WebSocketServer get instance => _instance;
  HttpServer? _server;
  WebSocketSink? _remoteSink;
  final _controller = StreamController<String>.broadcast();
  final _sink = StreamController<String>();
  late final Stream<String> _sinkStream;
  StreamSubscription? _sinkSubscription;

  WebSocketServer._internal() {
    _sinkStream = _sink.stream.asBroadcastStream();
  }

  StreamChannel<String>? get channel =>
      _server == null ? null : StreamChannel(_controller.stream, _sink.sink);

  Future<void> start(String portFile) async {
    if (_server != null) {
      throw StateError('WebSocket服务器已经启动');
    }
    if (portFile.isEmpty) {
      logger.info('未指定端口保存文件，不开启WebSocket服务器');
      return;
    }
    // 创建WebSocket服务器
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final port = _server!.port;
    logger.info('WebSocket服务器在端口 $port 启动');

    // 保存端口到临时文件
    await _savePortToFile(port, portFile);

    // 监听WebSocket连接
    _server!
        .transform(WebSocketTransformer())
        .map(IOWebSocketChannel.new)
        .listen((channel) async {
      try {
        logger.info('客户端已连接');
        // 断开旧连接
        try {
          await _remoteSink?.close();
          _remoteSink = null;
        } catch (e) {
          logger.severe('关闭旧WebSocket连接时出错: $e');
        }

        // 停止旧的listen
        try {
          await _sinkSubscription?.cancel();
          _sinkSubscription = null;
        } catch (e) {
          logger.severe('停止旧sink订阅时出错: $e');
        }

        _remoteSink = channel.sink;

        // 将WebSocket的数据重定向到controller
        channel.stream.cast<String>().listen((data) {
          _controller.add(data);
        }, onDone: () async {
          logger.info('客户端已断开');
          final remoteSink = _remoteSink;
          _remoteSink = null;
          try {
            await remoteSink?.close();
          } catch (e) {
            logger.severe('关闭输出流时出错: $e');
          }
        }, onError: (e) async {
          logger.severe('客户端连接出错: $e');
          final remoteSink = _remoteSink;
          _remoteSink = null;
          try {
            await remoteSink?.close();
          } catch (e) {
            logger.severe('关闭输出流时出错: $e');
          }
        });

        // 将sink的数据发送到WebSocket
        _sinkSubscription = _sinkStream.listen((data) {
          _remoteSink?.add(data);
        });
      } catch (e) {
        logger.severe('处理WebSocket连接时出错: $e');
        try {
          await channel.sink.close();
        } catch (e) {
          logger.severe('关闭WebSocket连接时出错: $e');
        }
      }
    });
  }

  Future<void> _savePortToFile(int port, String portFile) async {
    try {
      final file = File(portFile);
      await file.writeAsString(port.toString());
      logger.info('端口已保存到文件: ${file.path}');
    } catch (e) {
      logger.severe('保存端口到文件时出错: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _remoteSink?.close();
    await _server?.close();
    await _sinkSubscription?.cancel();
  }
}
