import 'package:flutter_test/flutter_test.dart';
import 'package:app_manager_plugin/app_manager_plugin.dart';
import 'package:app_manager_plugin/app_manager_plugin_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Mock implementation of the platform interface.
class MockAppManagerPluginPlatform
    with
        MockPlatformInterfaceMixin // Use MockPlatformInterfaceMixin for verification
    implements
        AppManagerPluginPlatform {
  // Store expected calls and responses
  String? _expectedPlatformVersion;
  List<Map<String, dynamic>>? _expectedApps;
  bool? _expectedIncludeSystemApps;
  List<String>? _expectedWithPermissions;
  bool? _expectedMatchAll;

  void setExpectedPlatformVersion(String version) {
    _expectedPlatformVersion = version;
  }

  void setExpectedApps(
    List<Map<String, dynamic>>? apps, {
    bool? includeSystemApps,
    List<String>? withPermissions,
    bool? matchAll,
  }) {
    _expectedApps = apps;
    _expectedIncludeSystemApps = includeSystemApps;
    _expectedWithPermissions = withPermissions;
    _expectedMatchAll = matchAll;
  }

  @override
  Future<String?> getPlatformVersion() async {
    return _expectedPlatformVersion;
  }

  @override
  Future<List<InstalledApp>?> getInstalledApps({
    bool includeSystemApps = true,
    List<String>? withPermissions,
    bool matchAll = false,
  }) async {
    // Verify if the expected parameter was passed (if set)
    if (_expectedIncludeSystemApps != null) {
      expect(includeSystemApps, _expectedIncludeSystemApps);
    }
    if (_expectedWithPermissions != null) {
      expect(withPermissions, _expectedWithPermissions);
    }
    if (_expectedMatchAll != null) {
      expect(matchAll, _expectedMatchAll);
    }
    if (_expectedApps == null) {
      return null;
    }
    // Simulate the mapping that happens in the method channel implementation
    return _expectedApps!.map((map) => InstalledApp.fromMap(map)).toList();
  }
}

void main() {
  // Ensure bindings are initialized for testing
  TestWidgetsFlutterBinding.ensureInitialized();

  // Use the actual method channel implementation but mock the platform interface
  final AppManagerPluginPlatform initialPlatform =
      AppManagerPluginPlatform.instance;
  late MockAppManagerPluginPlatform mockPlatform;
  late AppManagerPlugin plugin;

  setUp(() {
    mockPlatform = MockAppManagerPluginPlatform();
    AppManagerPluginPlatform.instance = mockPlatform; // Inject the mock
    plugin = AppManagerPlugin();
  });

  tearDown(() {
    AppManagerPluginPlatform.instance =
        initialPlatform; // Restore original platform
  });

  test('getPlatformVersion', () async {
    mockPlatform.setExpectedPlatformVersion('Android 99');
    expect(await plugin.getPlatformVersion(), 'Android 99');
  });

  group('getInstalledApps', () {
    final List<Map<String, dynamic>> mockAppMapList = [
      {
        'app_name': 'App One',
        'package_name': 'com.example.one',
        'version_name': '1.0',
        'version_code': 10,
        'icon': 'base64icon1'
      },
      {
        'app_name': 'App Two',
        'package_name': 'com.example.two',
        'version_name': '2.1',
        'version_code': 21.0, // Test double for version code
        'icon': null
      },
    ];

    final List<InstalledApp> expectedAppList = [
      const InstalledApp(
        appName: 'App One',
        packageName: 'com.example.one',
        versionName: '1.0',
        versionCode: 10,
        icon: 'base64icon1',
      ),
      const InstalledApp(
        appName: 'App Two',
        packageName: 'com.example.two',
        versionName: '2.1',
        versionCode: 21, // Expect int
        icon: null,
      ),
    ];

    test('returns list of apps with default includeSystemApps=true', () async {
      mockPlatform.setExpectedApps(mockAppMapList, includeSystemApps: true);
      final result = await plugin.getInstalledApps();
      expect(result, isA<List<InstalledApp>>());
      expect(result, equals(expectedAppList));
    });

    test('returns list of apps with includeSystemApps=false', () async {
      // Use slightly different data for this case if needed, or reuse
      final List<Map<String, dynamic>> mockAppMapListFiltered = [
        {
          'app_name': 'App One',
          'package_name': 'com.example.one',
          'version_name': '1.0',
          'version_code': 10,
          'icon': 'base64icon1'
        }
      ];
      final List<InstalledApp> expectedAppListFiltered = [
        const InstalledApp(
          appName: 'App One',
          packageName: 'com.example.one',
          versionName: '1.0',
          versionCode: 10,
          icon: 'base64icon1',
        )
      ];

      mockPlatform.setExpectedApps(mockAppMapListFiltered,
          includeSystemApps: false);
      final result = await plugin.getInstalledApps(includeSystemApps: false);
      expect(result, isA<List<InstalledApp>>());
      expect(result, equals(expectedAppListFiltered));
    });

    test('normalizes AndroidPermission enums and passes matchAll', () async {
      // Expect normalized manifest strings
      mockPlatform.setExpectedApps(
        mockAppMapList,
        includeSystemApps: true,
        withPermissions: [
          'android.permission.POST_NOTIFICATIONS',
          'android.permission.CAMERA',
        ],
        matchAll: true,
      );

      final result = await plugin.getInstalledApps(
        withPermissions: [
          AndroidPermission.notifications,
          AndroidPermission.camera,
        ],
        matchAll: true,
      );
      expect(result, equals(expectedAppList));
    });

    test('accepts mixed enums and raw strings', () async {
      mockPlatform.setExpectedApps(
        mockAppMapList,
        withPermissions: [
          'android.permission.POST_NOTIFICATIONS',
          'android.permission.RECORD_AUDIO',
        ],
      );

      final result = await plugin.getInstalledApps(
        withPermissions: [
          AndroidPermission.notifications,
          'android.permission.RECORD_AUDIO',
        ],
      );
      expect(result, equals(expectedAppList));
    });

    test('returns null when platform returns null', () async {
      mockPlatform.setExpectedApps(null, includeSystemApps: true);
      expect(await plugin.getInstalledApps(), isNull);
    });
  });

  group('InstalledApp.fromMap', () {
    test('parses map correctly with all fields', () {
      final map = {
        'app_name': 'Test App',
        'package_name': 'com.test.app',
        'version_name': '1.2.3',
        'version_code': 123,
        'icon': 'base64test'
      };
      final app = InstalledApp.fromMap(map);
      expect(app.appName, 'Test App');
      expect(app.packageName, 'com.test.app');
      expect(app.versionName, '1.2.3');
      expect(app.versionCode, 123);
      expect(app.icon, 'base64test');
    });

    test('parses map correctly with missing/null fields', () {
      final map = {
        'app_name': 'Test App Nulls',
        'package_name': 'com.test.nulls',
        // missing version_name
        'version_code': null,
        'icon': null
      };
      final app = InstalledApp.fromMap(map);
      expect(app.appName, 'Test App Nulls');
      expect(app.packageName, 'com.test.nulls');
      expect(app.versionName, isNull);
      expect(app.versionCode, isNull);
      expect(app.icon, isNull);
    });

    test('parses map correctly with double versionCode', () {
      final map = {
        'app_name': 'Test App Double VC',
        'package_name': 'com.test.doublevc',
        'version_name': '1.0',
        'version_code': 45.0, // Double value
        'icon': null
      };
      final app = InstalledApp.fromMap(map);
      expect(app.versionCode, 45);
    });

    test('parses map correctly with string versionCode', () {
      final map = {
        'app_name': 'Test App String VC',
        'package_name': 'com.test.stringvc',
        'version_name': '1.0',
        'version_code': '67', // String value
        'icon': null
      };
      final app = InstalledApp.fromMap(map);
      expect(app.versionCode, 67);
    });

    test('uses default names for null/missing name fields', () {
      final Map<String, dynamic> map = {
        // missing app_name
        // missing package_name
      };
      final app = InstalledApp.fromMap(map);
      expect(app.appName, 'Unknown App');
      expect(app.packageName, 'Unknown Package');
    });
  });
}
