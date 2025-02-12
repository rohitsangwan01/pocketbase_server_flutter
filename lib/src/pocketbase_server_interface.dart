typedef PocketbaseEventCallback = void Function(String event, String data);

abstract class PocketbaseServerInterface {
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
    throw UnimplementedError();
  }

  Future<void> stop() async {
    throw UnimplementedError();
  }

  Future<bool> get isRunning {
    throw UnimplementedError();
  }

  Future<String?> get pocketbaseMobileVersion {
    throw UnimplementedError();
  }

  Future<String?> get localIpAddress {
    throw UnimplementedError();
  }

  void setEventCallback({
    PocketbaseEventCallback? callback,
  }) {
    throw UnimplementedError();
  }
}

class PocketbaseServerDefault extends PocketbaseServerInterface {
  PocketbaseServerDefault._();
  static PocketbaseServerDefault? _instance;
  static PocketbaseServerDefault get instance =>
      _instance ??= PocketbaseServerDefault._();
}
