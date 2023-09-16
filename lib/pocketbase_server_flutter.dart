import 'package:flutter/services.dart';

class PocketbaseServerFlutter {
  static const _channel = MethodChannel('com.pocketbase.mobile.channel');
  static const _messageConnector = BasicMessageChannel(
    "com.pocketbase.mobile.message_connector",
    StandardMessageCodec(),
  );

  static Future<void> start({
    String? hostName,
    String? port,
    String? dataPath,
    bool? enablePocketbaseApiLogs,
  }) async {
    await _channel.invokeMethod("start", {
      "hostName": hostName,
      "port": port,
      "dataPath": dataPath,
      "enablePocketbaseApiLogs": enablePocketbaseApiLogs,
    });
  }

  static Future<void> stop() => _channel.invokeMethod("stop");

  static Future get isRunning => _channel.invokeMethod("isRunning");

  static Future get pocketbaseMobileVersion => _channel.invokeMethod("version");

  static Future<String?> get localIpAddress =>
      _channel.invokeMethod("getLocalIpAddress");

  static void setEventCallback({
    Function(String event, String data)? callback,
  }) async {
    if (callback == null) {
      _messageConnector.setMessageHandler(null);
      return;
    }
    _messageConnector.setMessageHandler((dynamic message) async {
      callback.call(message["type"], message["data"]);
      return null;
    });
  }
}
