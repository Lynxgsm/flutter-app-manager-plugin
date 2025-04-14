import 'app_manager_plugin_platform_interface.dart';
import 'src/models/installed_app.dart';

export 'src/widgets/app_icon_widget.dart';
export 'src/models/installed_app.dart';

class AppManagerPlugin {
  Future<String?> getPlatformVersion() {
    return AppManagerPluginPlatform.instance.getPlatformVersion();
  }

  Future<List<InstalledApp>?> getInstalledApps(
      {bool includeSystemApps = true}) {
    return AppManagerPluginPlatform.instance
        .getInstalledApps(includeSystemApps: includeSystemApps);
  }
}
