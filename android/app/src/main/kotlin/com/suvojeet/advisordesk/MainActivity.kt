package com.suvojeet.advisordesk

import android.content.Context
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    
    

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
            val packageInfo = applicationContext.packageManager.getPackageInfo(applicationContext.packageName, 0)
            packageInfo.versionName ?: "N/A"
        } catch (e: Exception) {
            "N/A"
        }
    }
}
