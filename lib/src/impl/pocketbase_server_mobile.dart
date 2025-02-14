import 'package:flutter/services.dart';
import 'package:pocketbase_server_flutter/src/pocketbase_server_interface.dart';

class PocketbaseServerMobile extends PocketbaseServerInterface {
  PocketbaseServerMobile._();
  static PocketbaseServerMobile? _instance;
  static PocketbaseServerMobile get instance =>
      _instance ??= PocketbaseServerMobile._();

  final _channel = const MethodChannel('com.pocketbase.mobile.channel');
  final _messageConnector = const BasicMessageChannel(
    "com.pocketbase.mobile.message_connector",
    StandardMessageCodec(),
  );

  @override
  Future<void> start({
    required String superUserEmail,
    required String superUserPassword,
    String? pocketbaseExecutable,
    String? hostName,
    String? port,
    String? dataPath,
    String? staticFilesPath,
    String? hookFilesPath,
    bool? enablePocketbaseApiLogs,
  }) async {
    await _channel.invokeMethod("start", {
      "hostName": hostName,
      "port": port,
      "dataPath": dataPath,
      "staticFilesPath": staticFilesPath,
      "enablePocketbaseApiLogs": enablePocketbaseApiLogs,
      "superUserEmail": superUserEmail,
      "superUserPassword": superUserPassword,
      "hookFilesPath": hookFilesPath,
    });
  }

  @override
  Future<void> stop() => _channel.invokeMethod("stop");

  @override
  Future<bool> get isRunning async {
    var result = await _channel.invokeMethod("isRunning");
    return result ?? false;
  }

  @override
  Future<String?> get pocketbaseMobileVersion =>
      _channel.invokeMethod<String?>("version");

  @override
  Future<String?> get localIpAddress =>
      _channel.invokeMethod("getLocalIpAddress");

  @override
  void setEventCallback({
    PocketbaseEventCallback? callback,
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
