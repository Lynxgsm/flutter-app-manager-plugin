import 'package:flutter_test/flutter_test.dart';
import 'package:app_manager_plugin/app_manager_plugin.dart';
import 'package:app_manager_plugin/app_manager_plugin_platform_interface.dart';
import 'package:app_manager_plugin/app_manager_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAppManagerPluginPlatform
    with MockPlatformInterfaceMixin
    implements AppManagerPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AppManagerPluginPlatform initialPlatform = AppManagerPluginPlatform.instance;

  test('$MethodChannelAppManagerPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAppManagerPlugin>());
  });

  test('getPlatformVersion', () async {
    AppManagerPlugin appManagerPlugin = AppManagerPlugin();
    MockAppManagerPluginPlatform fakePlatform = MockAppManagerPluginPlatform();
    AppManagerPluginPlatform.instance = fakePlatform;

    expect(await appManagerPlugin.getPlatformVersion(), '42');
  });
}
