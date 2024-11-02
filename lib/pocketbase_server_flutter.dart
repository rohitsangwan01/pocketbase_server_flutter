import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'generated_bindings.dart';

class PocketbaseServerFlutter {
  static final NativeLibrary _bindings = NativeLibrary(_dylib);
  static NativeCallable<FlutterBridgeFunction>? _flutterBridgeCallback;

  static Future<void> start({
    required String hostName,
    required String port,
    required String dataPath,
    bool enablePocketbaseApiLogs = false,
  }) async {
    return compute(_startServer, {
      'hostName': hostName,
      'port': port,
      'dataPath': dataPath,
      'enablePocketbaseApiLogs': enablePocketbaseApiLogs,
    });
  }

  static Future<void> stop() async {
    _bindings.stopPocketbase();
  }

  static Future<bool> get isRunning async {
    return _bindings.isRunning() == 1;
  }

  static Future<String> get pocketbaseVersion async {
    return _bindings.getVersion().cast<Utf8>().toDartString();
  }

  static void setEventCallback({
    Function(String event, String data)? callback,
  }) async {
    if (_flutterBridgeCallback != null) {
      throw "Callback already set";
    }
    _flutterBridgeCallback ??= NativeCallable<FlutterBridgeFunction>.listener(
        (Pointer<Char> command, Pointer<Char> data) {
      callback?.call(
        command.cast<Utf8>().toDartString(),
        data.cast<Utf8>().toDartString(),
      );
    });
    _bindings.registerBridgeCallback(_flutterBridgeCallback!.nativeFunction);
  }

  /// This is a blocking function, call from Isolate
  static Future<void> _startServer(Map<String, dynamic> args) async {
    Pointer<Char> path =
        (args['dataPath'] as String).toNativeUtf8().cast<Char>();
    Pointer<Char> portPointer =
        (args['port'] as String).toNativeUtf8().cast<Char>();
    Pointer<Char> hostNamePointer =
        (args['hostName'] as String).toNativeUtf8().cast<Char>();
    int getApiLogs = args['enablePocketbaseApiLogs'] ? 1 : 0;
    _bindings.startPocketbase(
      path,
      portPointer,
      hostNamePointer,
      getApiLogs,
    );
    // Remove Resources
    calloc.free(path);
    calloc.free(portPointer);
    calloc.free(hostNamePointer);
  }

  static final DynamicLibrary _dylib = () {
    const String libName = 'libpocketbase';
    if (kIsWeb) throw "Not supported";
    if (Platform.isMacOS || Platform.isIOS) {
      return DynamicLibrary.open('$libName.framework/$libName');
    } else if (Platform.isAndroid || Platform.isLinux) {
      return DynamicLibrary.open('$libName.so');
    } else if (Platform.isWindows) {
      return DynamicLibrary.open('$libName.dll');
    }
    throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
  }();
}
