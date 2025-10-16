import 'app_manager_plugin_platform_interface.dart';
import 'src/models/installed_app.dart';
import 'src/models/android_permission.dart';

export 'src/widgets/app_icon_widget.dart';
export 'src/models/installed_app.dart';
export 'src/models/android_permission.dart';

class AppManagerPlugin {
  Future<String?> getPlatformVersion() {
    return AppManagerPluginPlatform.instance.getPlatformVersion();
  }

  Future<List<InstalledApp>?> getInstalledApps({
    bool includeSystemApps = true,
    List<Object>? withPermissions, // accepts AndroidPermission or String
    bool matchAll = false,
  }) {
    final normalized = withPermissions == null
        ? null
        : normalizePermissionInputs(withPermissions);
    return AppManagerPluginPlatform.instance.getInstalledApps(
      includeSystemApps: includeSystemApps,
      withPermissions: normalized,
      matchAll: matchAll,
    );
  }
}
