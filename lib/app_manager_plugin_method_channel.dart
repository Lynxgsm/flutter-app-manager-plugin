import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_manager_plugin_platform_interface.dart';
import 'src/models/installed_app.dart';

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
  Future<List<InstalledApp>?> getInstalledApps({
    bool includeSystemApps = true,
    List<String>? withPermissions,
    bool matchAll = false,
  }) async {
    final List<dynamic>? rawApps =
        await methodChannel.invokeMethod<List<dynamic>>(
      'getInstalledApps',
      {
        'includeSystemApps': includeSystemApps,
        if (withPermissions != null) 'withPermissions': withPermissions,
        'matchAll': matchAll,
      },
    );
    // Now map the raw list of maps to a list of InstalledApp objects.
    return rawApps
        ?.map((app) =>
            InstalledApp.fromMap(Map<String, dynamic>.from(app as Map)))
        .toList();
  }
}
