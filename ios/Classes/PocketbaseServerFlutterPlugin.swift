import Flutter
import PocketbaseMobile
import UIKit

public class PocketbaseServerFlutterPlugin: NSObject, FlutterPlugin {
  static var channel: FlutterMethodChannel? = nil
  static var messageConnector: FlutterBasicMessageChannel? = nil
  static var isRunning = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = PocketbaseServerFlutterPlugin()
    channel = FlutterMethodChannel(name: "com.pocketbase.mobile.channel", binaryMessenger: registrar.messenger())
    messageConnector = FlutterBasicMessageChannel(name: "com.pocketbase.mobile.message_connector", binaryMessenger: registrar.messenger())
    let handler = PocketMobileCallbackHandler()
    PocketbaseMobileRegisterNativeBridgeCallback(handler)
    registrar.addMethodCallDelegate(instance, channel: channel!)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "start" {
      PocketbaseServerFlutterPlugin.startPocketbase(args: call.arguments, result: result)
    } else if call.method == "stop" {
      PocketbaseServerFlutterPlugin.stopPocketbase()
      result(nil)
    } else if call.method == "isRunning" {
      result(PocketbaseServerFlutterPlugin.isRunning)
    } else if call.method == "version" {
      result(PocketbaseMobileGetVersion())
    } else if call.method == "getLocalIpAddress" {
      result(PocketbaseServerFlutterPlugin.getLocalIpAddress())
    } else {
      result(FlutterMethodNotImplemented)
      return
    }
  }

  static func startPocketbase(args: Any?, result: @escaping FlutterResult) {
    let argument = args as? [String: Any]
    let hostName: String = (argument?["hostName"] as? String) ?? "127.0.0.1"
    let port: String = (argument?["port"] as? String) ?? "8090"
    let dataPath = (argument?["dataPath"] as? String) ?? getDefaultDirectory()
    let enablePocketbaseApiLogs: Bool = (argument?["enablePocketbaseApiLogs"] as? Bool) ?? true
    if dataPath == nil {
      result(FlutterError(code: "dataPathError", message: "Please pass valid dataPath", details: nil))
      return
    }
    DispatchQueue.global(qos: .userInitiated).async {
      PocketbaseMobileStartPocketbase(dataPath!, hostName, port, enablePocketbaseApiLogs)
      self.isRunning = true
    }
    result(nil)
  }

  static func stopPocketbase() {
    DispatchQueue.global(qos: .userInitiated).async {
      self.isRunning = false
      PocketbaseMobileStopPocketbase()
    }
  }

  static func getDefaultDirectory() -> String? {
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    return paths.first
  }

  static func getLocalIpAddress() -> String? {
    var address: String?
    var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
    if getifaddrs(&ifaddr) == 0 {
      var ptr = ifaddr
      while ptr != nil {
        defer { ptr = ptr?.pointee.ifa_next }
        guard let interface = ptr?.pointee else { return "" }
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
          let name = String(cString: interface.ifa_name)
          if name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
            address = String(cString: hostname)
          }
        }
      }
      freeifaddrs(ifaddr)
    }
    return address
  }
}

class PocketMobileCallbackHandler: NSObject, PocketbaseMobileNativeBridgeProtocol {
  func handleCallback(_ p0: String?, p1: String?) -> String {
    DispatchQueue.main.async {
      if p0 == "error" {
        PocketbaseServerFlutterPlugin.isRunning = false
      }
      PocketbaseServerFlutterPlugin.messageConnector?.sendMessage(["type": p0 ?? "", "data": p1 ?? ""])
    }
    return "reply from ios native"
  }
}
