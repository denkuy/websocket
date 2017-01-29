/// Command-line WebSocket client library for the Angel framework.
library angel_websocket.io;

import 'dart:async';
import 'dart:io';
import 'package:angel_client/angel_client.dart';
import 'package:http/http.dart' as http;
import 'package:json_god/json_god.dart' as god;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'angel_websocket.dart';
import 'base_websocket_client.dart';
export 'package:angel_client/angel_client.dart';
export 'angel_websocket.dart';

final RegExp _straySlashes = new RegExp(r"(^/)|(/+$)");

/// Queries an Angel server via WebSockets.
class WebSockets extends BaseWebSocketClient {
  WebSockets(String path) : super(new http.Client(), path);

  @override
  Future<WebSocketChannel> getConnectedWebSocket() async {
    var socket = await WebSocket.connect(basePath);
    return new IOWebSocketChannel(socket);
  }

  @override
  WebSocketsService service<T>(String path,
      {Type type, AngelDeserializer deserializer}) {
    String uri = path.replaceAll(_straySlashes, '');
    return new WebSocketsService(socket, this, uri, T != dynamic ? T : type);
  }

  @override
  serialize(x) => god.serialize(x);
}

class WebSocketsService extends BaseWebSocketService {
  final Type type;

  WebSocketsService(WebSocketChannel socket, Angel app, String uri, this.type)
      : super(socket, app, uri);

  @override
  serialize(WebSocketAction action) => god.serialize(action);

  @override
  deserialize(x) {
    if (type != null && type != dynamic) {
      return god.deserializeDatum(x, outputType: type);
    } else
      return super.deserialize(x);
  }
}