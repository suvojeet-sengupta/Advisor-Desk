package com.suvojeet.advisordesk

import android.content.Context
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle

class MainActivity: FlutterFragmentActivity() {

    private val APP_INFO_CHANNEL = "com.suvojeet.advisordesk/app_info"
    private val SHORTCUT_CHANNEL = "com.suvojeet.advisordesk/shortcuts"
    private var shortcutAction: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        shortcutAction = intent.action
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // App Info Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_INFO_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getAppVersion") {
                result.success(getAppVersion())
            } else {
                result.notImplemented()
            }
        }

        // Shortcut Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHORTCUT_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getShortcutAction") {
                result.success(shortcutAction)
                shortcutAction = null // Consume the action
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val action = intent.action
        if (action != null && (action.startsWith("com.suvojeet.advisordesk.") || action == "android.intent.action.VIEW")) {
            flutterEngine?.dartExecutor?.binaryMessenger?.let {
                MethodChannel(it, SHORTCUT_CHANNEL).invokeMethod("newShortcutAction", action)
            }
        }
    }

    private fun getAppVersion(): String {
        return try {
            val packageInfo = applicationContext.packageManager.getPackageInfo(applicationContext.packageName, 0)
            packageInfo.versionName ?: "N/A"
        } catch (e: Exception) {
            "N/A"
        }
    }
}
