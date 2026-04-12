import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../storage/secure_storage.dart';
import 'ws_event.dart';

class WsClient {
  final SecureStorageService _storage;

  WebSocketChannel? _channel;
  StreamController<WsEvent>? _controller;
  bool _isConnected = false;

  WsClient(this._storage);

  bool get isConnected => _isConnected;

  Stream<WsEvent> connect(String url) {
    _controller?.close();
    _controller = StreamController<WsEvent>.broadcast();
    _initConnection(url);
    return _controller!.stream;
  }

  Future<void> _initConnection(String url) async {
    try {
      final token = await _storage.read(
        key: SecureStorageServiceImpl.kAccessToken,
      );

      // Append token as query param — WebSocket headers are not
      // universally supported across platforms.
      final uri = Uri.parse(
        token != null ? '$url?token=$token' : url,
      );

      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;
      _controller?.add(const WsConnected());

      _channel!.stream.listen(
        (raw) {
          try {
            final data = jsonDecode(raw as String) as Map<String, dynamic>;
            _controller?.add(WsMessage(data));
          } catch (_) {
            // Non-JSON frame — ignore
          }
        },
        onError: (Object e) {
          _isConnected = false;
          _controller?.add(WsError(e));
        },
        onDone: () {
          _isConnected = false;
          _controller?.add(const WsDisconnected());
        },
      );
    } catch (e) {
      _isConnected = false;
      _controller?.add(WsError(e));
    }
  }

  void send(Map<String, dynamic> data) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void disconnect() {
    _isConnected = false;
    _channel?.sink.close();
    _controller?.close();
    _channel = null;
    _controller = null;
  }
}
