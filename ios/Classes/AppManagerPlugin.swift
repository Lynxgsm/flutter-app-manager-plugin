import Flutter
import UIKit

public class AppManagerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "app_manager_plugin", binaryMessenger: registrar.messenger())
    let instance = AppManagerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getInstalledApps":
        // iOS does not allow querying installed apps due to privacy restrictions.
        // Returning an empty list.
        // let includeSystemApps = (call.arguments as? [String: Any])?["includeSystemApps"] as? Bool ?? true // Argument is received but ignored
        result([]) // Return empty list
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
