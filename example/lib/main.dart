import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:app_manager_plugin/app_manager_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>>? _apps = [];
  bool _loading = false;
  String? _error;
  final _appManagerPlugin = AppManagerPlugin();

  @override
  void initState() {
    super.initState();
    // Optionally load apps on init
    // _fetchInstalledApps();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _fetchInstalledApps() async {
    setState(() {
      _loading = true;
      _error = null;
      _apps = []; // Clear previous results
    });

    List<Map<String, dynamic>>? apps;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle potential null returns or other exceptions.
    try {
      apps = await _appManagerPlugin.getInstalledApps();
    } on PlatformException catch (e) {
      _error = "Failed to get apps: '${e.message}'.";
    } catch (e) {
      _error = "Failed to get apps: ${e.toString()}";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _loading = false;
      if (apps != null) {
        _apps = apps;
      }
      // _error might have been set in the catch block
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App Manager Plugin Example'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _fetchInstalledApps,
                child: const Text('Get Installed Apps'),
              ),
            ),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: $_error',
                    style: const TextStyle(color: Colors.red)),
              )
            else if (_apps != null && _apps!.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _apps!.length,
                  itemBuilder: (context, index) {
                    final app = _apps![index];
                    final appName = app['app_name'] ?? 'Unknown App';
                    final packageName =
                        app['package_name'] ?? 'Unknown Package';
                    final versionName = app['version_name'] ?? 'N/A';
                    final versionCode = app['version_code']?.toString() ??
                        'N/A'; // Ensure versionCode is string
                    final String? iconBase64 =
                        app['icon'] as String?; // Get icon string

                    return ListTile(
                      leading: AppIconWidget(
                        iconBase64: iconBase64,
                        // Optional: specify width/height if different from default
                        // width: 48,
                        // height: 48,
                      ),
                      title: Text(appName),
                      subtitle: Text(
                          'Package: $packageName\nVersion: $versionName ($versionCode)'),
                      isThreeLine: true, // Make space for the subtitle
                    );
                  },
                ),
              )
            else
              const Center(child: Text('No apps found or fetched yet.')),
          ],
        ),
      ),
    );
  }
}
