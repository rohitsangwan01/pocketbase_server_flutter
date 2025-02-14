// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:pocketbase_server_flutter/src/pocketbase_server_interface.dart';

class PocketbaseServerDesktop extends PocketbaseServerInterface {
  PocketbaseServerDesktop._();
  static PocketbaseServerDesktop? _instance;
  static PocketbaseServerDesktop get instance =>
      _instance ??= PocketbaseServerDesktop._();
  static final NetworkInfo _networkInfo = NetworkInfo();

  PocketbaseEventCallback? _callback;
  Process? _pocketbaseProcess;
  final _logEvent = "log";
  final _errorEvent = "error";
  final _onBootStrapEvent = "OnBootstrap";
  final _onTerminateEvent = "OnTerminate";

  @override
  Future<void> start({
    required String superUserEmail,
    required String superUserPassword,
    String? pocketbaseExecutable,
    String? dataPath,
    String? hostName,
    String? port,
    String? staticFilesPath,
    String? hookFilesPath,
    bool? enablePocketbaseApiLogs,
  }) async {
    if (_pocketbaseProcess != null) {
      _pocketbaseProcess?.kill();
      _pocketbaseProcess = null;
    }

    if (pocketbaseExecutable == null) {
      throw "Pocketbase Executable not found";
    }

    // First Ask permission on MacOS to execute this file
    if (Platform.isMacOS || Platform.isLinux) {
      ProcessResult result = await Process.run(
        "chmod",
        ["+x", pocketbaseExecutable],
        runInShell: true,
      );

      print("Asked for permission ${result.parseResult()}  ");
    }

    // Create super User
    ProcessResult superUserResult = await Process.run(
      pocketbaseExecutable,
      ["superuser", "upsert", superUserEmail, superUserPassword],
    );
    print("SuperUser: ${superUserResult.parseResult()}");

    // Start Server
    List<String> args = ["serve"];
    String host = hostName ?? "127.0.0.1";
    String portName = port ?? "8090";
    args.addAll(["--http", "$host:$portName"]);

    if (dataPath != null) {
      args.addAll(["--dir", dataPath]);
    }

    if (staticFilesPath != null) {
      args.addAll(['--publicDir', staticFilesPath]);
    }
    if (hookFilesPath != null) {
      args.addAll(['--hooksDir', hookFilesPath]);
    }

    print("Running Pocketbase with $args");
    Process process = await Process.start(pocketbaseExecutable, args);
    _callback?.call(_onBootStrapEvent, "");
    process.stdout.listen((e) {
      String data = utf8.decode(e);
      _callback?.call(_logEvent, data);
    });
    process.stderr.listen((e) {
      String data = utf8.decode(e);
      _callback?.call(_errorEvent, data);
    });
    process.exitCode.then((value) {
      _callback?.call(_onTerminateEvent, "ExitCode: $value");
      _pocketbaseProcess = null;
    });
    _pocketbaseProcess = process;
  }

  @override
  Future<void> stop() async {
    _pocketbaseProcess?.kill();
    _pocketbaseProcess = null;
  }

  @override
  Future<bool> get isRunning async {
    return _pocketbaseProcess != null;
  }

  @override
  Future<String?> get pocketbaseMobileVersion async {
    return null;
  }

  @override
  Future<String?> get localIpAddress async {
    return _networkInfo.getWifiIP();
  }

  @override
  void setEventCallback({
    PocketbaseEventCallback? callback,
  }) async {
    _callback = callback;
  }
}

extension _ProcessResultExtension on ProcessResult {
  String parseResult() {
    dynamic stdOut = stdout;
    dynamic stdErr = stderr;

    String resultString = "";

    if (stdOut is String) {
      resultString = stdOut;
    } else if (stdOut is Uint8List) {
      resultString = utf8.decode(stdOut);
    }

    if (stdErr is String) {
      resultString += stdErr;
    } else if (stdErr is Uint8List) {
      resultString += utf8.decode(stdErr);
    }

    return "$resultString ExitCode: $exitCode";
  }
}
