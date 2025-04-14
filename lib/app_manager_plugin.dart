import 'app_manager_plugin_platform_interface.dart';

export 'src/widgets/app_icon_widget.dart';

class AppManagerPlugin {
  Future<String?> getPlatformVersion() {
    return AppManagerPluginPlatform.instance.getPlatformVersion();
  }

  Future<List<Map<String, dynamic>>?> getInstalledApps(
      {bool includeSystemApps = true}) {
    return AppManagerPluginPlatform.instance
        .getInstalledApps(includeSystemApps: includeSystemApps);
  }
}
