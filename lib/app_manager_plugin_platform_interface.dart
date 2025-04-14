import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'app_manager_plugin_method_channel.dart';
import 'src/models/installed_app.dart';

abstract class AppManagerPluginPlatform extends PlatformInterface {
  /// Constructs a AppManagerPluginPlatform.
  AppManagerPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static AppManagerPluginPlatform _instance = MethodChannelAppManagerPlugin();

  /// The default instance of [AppManagerPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelAppManagerPlugin].
  static AppManagerPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AppManagerPluginPlatform] when
  /// they register themselves.
  static set instance(AppManagerPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<InstalledApp>?> getInstalledApps(
      {bool includeSystemApps = true}) {
    throw UnimplementedError('getInstalledApps() has not been implemented.');
  }
}
