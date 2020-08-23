import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class Signalling {
  WebSocketChannel wsChannel;
  WebSocketSink wsSink;

  void connect(String localIp, String port) {
    wsChannel = new IOWebSocketChannel.connect("ws://$localIp:$port");
    wsSink = wsChannel.sink;
  }

  void send(Map<String, dynamic> data) {
    String s = jsonEncode(data);
    wsSink.add(s);
  }

  Stream<dynamic> receive() {
    return wsChannel.stream;
  }
}
