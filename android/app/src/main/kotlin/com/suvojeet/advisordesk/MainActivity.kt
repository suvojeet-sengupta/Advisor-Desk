package com.suvojeet.advisordesk

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    
    

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

        
    }

    

    

    private val APP_INFO_CHANNEL = "com.suvojeet.advisordesk/app_info"

    private fun getAppVersion(): String {
        return try {
            val packageInfo = context.packageManager.getPackageInfo(context.packageName, 0)
            packageInfo.versionName ?: "N/A"
        } catch (e: Exception) {
            "N/A"
        }
    }
}
