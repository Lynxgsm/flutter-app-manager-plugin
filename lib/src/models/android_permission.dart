/// Canonical Android permission groups mapped to one or more manifest strings.
///
/// This enum provides simple names that expand to actual Android
/// `uses-permission` strings. Some entries map to multiple permissions
/// across API levels or vendor variants.
enum AndroidPermission {
  // Notifications (Android 13+)
  notifications(['android.permission.POST_NOTIFICATIONS']),

  // Alarm-related (varies across API/vendor)
  alarm([
    'com.android.alarm.permission.SET_ALARM', // legacy/vendor
    'android.permission.SCHEDULE_EXACT_ALARM', // Android 12+
    'android.permission.USE_EXACT_ALARM', // Android 14+
  ]),

  // Location
  locationWhenInUse([
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.ACCESS_COARSE_LOCATION'
  ]),
  locationAlways(['android.permission.ACCESS_BACKGROUND_LOCATION']),

  // Camera and microphone
  camera(['android.permission.CAMERA']),
  microphone(['android.permission.RECORD_AUDIO']),

  // Contacts / Phone / SMS
  contacts([
    'android.permission.READ_CONTACTS',
    'android.permission.WRITE_CONTACTS',
    'android.permission.GET_ACCOUNTS'
  ]),
  phone([
    'android.permission.CALL_PHONE',
    'android.permission.READ_PHONE_STATE',
    'android.permission.READ_PHONE_NUMBERS',
    'android.permission.USE_SIP',
  ]),
  callLog([
    'android.permission.READ_CALL_LOG',
    'android.permission.WRITE_CALL_LOG'
  ]),
  sms([
    'android.permission.SEND_SMS',
    'android.permission.RECEIVE_SMS',
    'android.permission.READ_SMS',
    'android.permission.RECEIVE_MMS',
    'android.permission.RECEIVE_WAP_PUSH',
  ]),

  // Storage / Media
  storageLegacy([
    'android.permission.READ_EXTERNAL_STORAGE',
    'android.permission.WRITE_EXTERNAL_STORAGE'
  ]),
  mediaImages(['android.permission.READ_MEDIA_IMAGES']), // Android 13+
  mediaVideo(['android.permission.READ_MEDIA_VIDEO']), // Android 13+
  mediaAudio(['android.permission.READ_MEDIA_AUDIO']), // Android 13+

  // Calendar
  calendar([
    'android.permission.READ_CALENDAR',
    'android.permission.WRITE_CALENDAR'
  ]),

  // Body sensors
  bodySensors(['android.permission.BODY_SENSORS']),
  bodySensorsBackground(
      ['android.permission.BODY_SENSORS_BACKGROUND']), // Android 14+

  // Nearby / Bluetooth
  nearbyDevices([
    'android.permission.NEARBY_WIFI_DEVICES',
    'android.permission.BLUETOOTH_CONNECT',
    'android.permission.BLUETOOTH_SCAN'
  ]), // Android 12/13

  // Overlay
  drawOverOtherApps(['android.permission.SYSTEM_ALERT_WINDOW']),

  // Usage access (special access, not runtime, but requested by some apps)
  packageUsageStats(['android.permission.PACKAGE_USAGE_STATS']);

  const AndroidPermission(this.manifestPermissions);
  final List<String> manifestPermissions;

  /// Flattens the enum value to its manifest permission strings.
  List<String> toManifestStrings() => manifestPermissions;
}

/// Helper to normalize a mixed list of [AndroidPermission] and raw String
/// permission names into manifest permission strings.
List<String> normalizePermissionInputs(List<Object> inputs) {
  final result = <String>[];
  for (final item in inputs) {
    if (item is AndroidPermission) {
      result.addAll(item.toManifestStrings());
    } else if (item is String) {
      result.add(item);
    } else {
      throw ArgumentError(
          'withPermissions contains unsupported type: ${item.runtimeType}');
    }
  }
  // Deduplicate while preserving order
  final seen = <String>{};
  final deduped = <String>[];
  for (final p in result) {
    if (seen.add(p)) deduped.add(p);
  }
  return deduped;
}
