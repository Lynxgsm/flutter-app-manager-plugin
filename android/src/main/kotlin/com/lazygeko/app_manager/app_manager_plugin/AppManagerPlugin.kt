package com.lazygeko.app_manager.app_manager_plugin

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import android.util.Log
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** AppManagerPlugin */
class AppManagerPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  companion object {
      private const val TAG = "AppManagerPlugin"
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext // Store context
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "app_manager_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
        "getPlatformVersion" -> {
          result.success("Android ${android.os.Build.VERSION.RELEASE}")
        }
        "getInstalledApps" -> {
          // Read the argument, default to true if not provided or wrong type
          val includeSystemApps = call.argument<Boolean>("includeSystemApps") ?: true
          getInstalledApps(result, includeSystemApps)
        }
        else -> {
          result.notImplemented()
        }
    }
  }

  private fun getInstalledApps(result: Result, includeSystemApps: Boolean) {
    try {
      val pm: PackageManager = context.packageManager
      // Get all installed applications
      val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
      val appList = mutableListOf<Map<String, Any?>>()

      for (packageInfo in packages) {
        val isSystemApp = (packageInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0

        // Filter based on the flag
        if (includeSystemApps || !isSystemApp) {
            val appInfo = mutableMapOf<String, Any?>()
            appInfo["app_name"] = packageInfo.loadLabel(pm).toString()
            appInfo["package_name"] = packageInfo.packageName
            try {
                val pInfo = pm.getPackageInfo(packageInfo.packageName, 0)
                appInfo["version_name"] = pInfo.versionName
                appInfo["version_code"] = pInfo.longVersionCode // Use longVersionCode for API 28+
            } catch (e: PackageManager.NameNotFoundException) {
                // Handle case where package info might not be found (should be rare)
                appInfo["version_name"] = null
                appInfo["version_code"] = null
            }
             // Add more info as needed, e.g., icon
            appInfo["icon"] = getEncodedIcon(pm, packageInfo.packageName)
            appList.add(appInfo)
        }
      }
      Log.d(TAG, "Returning ${appList.size} apps (includeSystemApps=$includeSystemApps)")
      result.success(appList)
    } catch (e: Exception) {
        result.error("getInstalledAppsFailed", "Failed to get installed apps: ${e.message}", null)
    }
  }


  // Optional: Function to get app icon as Base64 String
  
  private fun getEncodedIcon(pm: PackageManager, packageName: String): String? {
      return try {
          val iconDrawable: Drawable = pm.getApplicationIcon(packageName)
          Log.d(TAG, "Icon type for $packageName: ${iconDrawable::class.java.name}")

          val bitmap: Bitmap =
              if (iconDrawable is BitmapDrawable && iconDrawable.bitmap != null) {
                  // If it's already a BitmapDrawable, just use its bitmap
                   Log.d(TAG, "Using existing bitmap for $packageName")
                  iconDrawable.bitmap
              } else {
                  // Otherwise, create a new bitmap and draw the drawable onto it
                  Log.d(TAG, "Creating bitmap for $packageName")
                  val width = if (iconDrawable.intrinsicWidth > 0) iconDrawable.intrinsicWidth else 96 // Default width
                  val height = if (iconDrawable.intrinsicHeight > 0) iconDrawable.intrinsicHeight else 96 // Default height
                  val createdBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                  val canvas = Canvas(createdBitmap)
                  iconDrawable.setBounds(0, 0, canvas.width, canvas.height)
                  iconDrawable.draw(canvas)
                  createdBitmap
              }

          // Compress the bitmap to PNG and encode to Base64
          val stream = java.io.ByteArrayOutputStream()
          bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
          val encodedString = Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
           Log.d(TAG, "Encoded icon for $packageName successfully (length: ${encodedString.length})")
          encodedString

      } catch (e: PackageManager.NameNotFoundException) {
           Log.e(TAG, "Icon not found for package: $packageName", e)
          null
      } catch (e: Exception) {
           Log.e(TAG, "Error getting/encoding icon for $packageName", e)
          null
      }
  }
  

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
