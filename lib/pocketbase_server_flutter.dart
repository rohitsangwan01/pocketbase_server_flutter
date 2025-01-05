import 'dart:io';

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
    String? staticFilesPath,
    bool? enablePocketbaseApiLogs,
  }) async {
    await _channel.invokeMethod("start", {
      "hostName": hostName,
      "port": port,
      "dataPath": dataPath,
      "staticFilesPath": staticFilesPath,
      "enablePocketbaseApiLogs": enablePocketbaseApiLogs,
    });
  }

  static Future<void> stop() => _channel.invokeMethod("stop");

  static Future get isRunning => _channel.invokeMethod("isRunning");

  static Future get pocketbaseMobileVersion => _channel.invokeMethod("version");

  static Future<String?> get localIpAddress =>
      _channel.invokeMethod("getLocalIpAddress");

  static Future<void> copyAssetsToPath({
    required String path,
    required List<String> assets,
    bool overwriteExisting = false,
  }) async {
    final Directory assetDirectory = Directory(path);
    if (!await assetDirectory.exists()) {
      await assetDirectory.create(recursive: true);
    }

    if (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    for (String asset in assets) {
      String assetName = asset.split("/").last;
      String assetPath = "$path/$assetName";
      File file = File(assetPath);
      if (await file.exists()) {
        if (overwriteExisting) {
          await File(assetPath).delete();
        } else {
          continue;
        }
        var assetBytes = await rootBundle.load(asset);
        await file.writeAsBytes(assetBytes.buffer.asUint8List());
      }
    }
  }

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
