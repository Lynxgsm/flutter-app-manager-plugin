# app_manager_plugin

A Flutter plugin to list installed applications on Android devices, including app name, package name, version, and icon. Provides an option to include or exclude system apps.

## Features

- Fetches a list of installed applications.
- Provides app details: display name, package name, version name, version code.
- Retrieves app icons (encoded as Base64 PNG strings).
- Option to include or exclude system applications.
- Includes `AppIconWidget` helper to easily display fetched icons.
- Currently supports Android only.

## Getting Started

### Prerequisites

- Flutter SDK
- Android development environment

### Installation

1. Add the dependency to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     app_manager_plugin: ^0.0.1 # Use the latest version
   ```

2. Install the package:

   ```bash
   flutter pub get
   ```

### Android Setup

To query all installed apps on Android 11 (API 30) and higher, you **must** add the `QUERY_ALL_PACKAGES` permission to your app's `AndroidManifest.xml` file, located at `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android" ...>
    <!-- Add this line -->
    <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />

    <application ...>
        ...
    </application>
</manifest>
```

**Note:** Use of this permission is subject to Google Play policy restrictions. Ensure your app has a valid reason for needing visibility into all installed apps.

## Usage

Import the package and use the `AppManagerPlugin` class.

```dart
import 'package:flutter/material.dart';
import 'package:app_manager_plugin/app_manager_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<InstalledApp>? _apps;
  bool _loading = false;
  String? _error;
  bool _includeSystemApps = false;
  final _plugin = AppManagerPlugin();

  @override
  void initState() {
    super.initState();
    _fetchApps();
  }

  Future<void> _fetchApps() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final apps = await _plugin.getInstalledApps(includeSystemApps: _includeSystemApps);
      setState(() {
        _apps = apps;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to get apps: ${e.toString()}";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App Manager Example'),
        ),
        body: Column(
          children: [
            SwitchListTile(
              title: const Text('Include System Apps'),
              value: _includeSystemApps,
              onChanged: (value) {
                setState(() {
                  _includeSystemApps = value;
                });
                _fetchApps(); // Re-fetch when toggle changes
              },
            ),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
            else if (_apps != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _apps!.length,
                  itemBuilder: (context, index) {
                    final app = _apps![index];
                    return ListTile(
                      leading: AppIconWidget(
                        iconBase64: app.icon,
                        width: 48,
                        height: 48,
                      ),
                      title: Text(app.appName),
                      subtitle: Text(
                          '${app.packageName}\nVersion: ${app.versionName ?? 'N/A'} (${app.versionCode ?? 'N/A'})'),
                      isThreeLine: true,
                    );
                  },
                ),
              )
            else
              const Center(child: Text('No apps found.')),
          ],
        ),
      ),
    );
  }
}
```

## API

### `AppManagerPlugin`

- `Future<List<InstalledApp>?> getInstalledApps({bool includeSystemApps = true})`:
  Fetches the list of installed applications. Set `includeSystemApps` to `false` to exclude system apps.

### `InstalledApp`

A model class representing an installed application with the following properties:

- `String appName`
- `String packageName`
- `String? versionName`
- `int? versionCode`
- `String? icon` (Base64 encoded PNG)

### `AppIconWidget`

A helper widget to display an app icon from its Base64 string.

- `AppIconWidget({required String? iconBase64, double width = 40.0, double height = 40.0})`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

Specify your license here (e.g., MIT, Apache 2.0).
