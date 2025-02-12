import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pocketbase_server_flutter/src/impl/pocketbase_server_desktop.dart';
import 'package:pocketbase_server_flutter/src/pocketbase_server_interface.dart';
import 'package:pocketbase_server_flutter/src/impl/pocketbase_server_mobile.dart';

class PocketbaseServerFlutter {
  static final PocketbaseServerInterface _platform = _getPlatformImpl();

  static Future<void> start({
    required String superUserEmail,
    required String superUserPassword,
    String? pocketbaseExecutable,
    String? dataPath,
    String? hostName,
    String? port,
    String? staticFilesPath,
    String? hookFilesPath,
    bool? enablePocketbaseApiLogs,
  }) {
    return _platform.start(
      superUserEmail: superUserEmail,
      superUserPassword: superUserPassword,
      pocketbaseExecutable: pocketbaseExecutable,
      hostName: hostName,
      port: port,
      dataPath: dataPath,
      staticFilesPath: staticFilesPath,
      hookFilesPath: hookFilesPath,
      enablePocketbaseApiLogs: enablePocketbaseApiLogs,
    );
  }

  static Future<void> stop() => _platform.stop();

  static Future<bool?> get isRunning => _platform.isRunning;

  static Future get pocketbaseMobileVersion =>
      _platform.pocketbaseMobileVersion;

  static Future<String?> get localIpAddress => _platform.localIpAddress;

  static void setEventCallback({
    Function(String event, String data)? callback,
  }) =>
      _platform.setEventCallback(callback: callback);

  // Copy all assets from given asset folder to the given path
  static Future<void> copyAssetsFolderToPath({
    required String path,
    required String assetFolder,
    bool overwriteExisting = false,
  }) async {
    var assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assetsList = assetManifest
        .listAssets()
        .where((string) => string.startsWith(assetFolder))
        .toList();
    return copyAssetsToPath(
      path: path,
      assets: assetsList,
      overwriteExisting: overwriteExisting,
    );
  }

  // Copy all assets from given asset files to the given path
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
      }
      var assetBytes = await rootBundle.load(asset);
      await file.writeAsBytes(assetBytes.buffer.asUint8List());
    }
  }

  static PocketbaseServerInterface _getPlatformImpl() {
    if (kIsWeb) return PocketbaseServerDefault.instance;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        return PocketbaseServerMobile.instance;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return PocketbaseServerDesktop.instance;
      default:
        return PocketbaseServerDefault.instance;
    }
  }
}
