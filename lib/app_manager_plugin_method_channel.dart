import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_manager_plugin_platform_interface.dart';

/// An implementation of [AppManagerPluginPlatform] that uses method channels.
class MethodChannelAppManagerPlugin extends AppManagerPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('app_manager_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<Map<String, dynamic>>?> getInstalledApps() async {
    final List<dynamic>? apps =
        await methodChannel.invokeMethod<List<dynamic>>('getInstalledApps');
    // The result from Kotlin is List<Map<String, Any?>>.
    // We need to cast it carefully to List<Map<String, dynamic>> for Dart.
    return apps?.map((app) => Map<String, dynamic>.from(app as Map)).toList();
  }
}
