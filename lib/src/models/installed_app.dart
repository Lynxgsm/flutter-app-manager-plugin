import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

/// Represents information about an installed application.
@immutable
class InstalledApp extends Equatable {
  /// The display name of the application.
  final String appName;

  /// The unique package name identifier.
  final String packageName;

  /// The version name (e.g., "1.0.0"). Can be null.
  final String? versionName;

  /// The version code (an integer). Can be null.
  final int? versionCode;

  /// The Base64 encoded PNG representation of the app icon. Can be null.
  final String? icon;

  /// Creates an instance of [InstalledApp].
  const InstalledApp({
    required this.appName,
    required this.packageName,
    this.versionName,
    this.versionCode,
    this.icon,
  });

  /// Creates an [InstalledApp] instance from a map (typically from platform channel).
  factory InstalledApp.fromMap(Map<String, dynamic> map) {
    // Helper to safely cast int? (Long on Android can be int or double in Dart sometimes)
    int? safeCastInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
    }

    return InstalledApp(
      appName: map['app_name'] as String? ?? 'Unknown App',
      packageName: map['package_name'] as String? ?? 'Unknown Package',
      versionName: map['version_name'] as String?,
      versionCode: safeCastInt(map['version_code']), // Use safe cast
      icon: map['icon'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        appName,
        packageName,
        versionName,
        versionCode,
        icon,
      ];

  @override
  bool get stringify => true; // Optional: Makes toString() more helpful
}
