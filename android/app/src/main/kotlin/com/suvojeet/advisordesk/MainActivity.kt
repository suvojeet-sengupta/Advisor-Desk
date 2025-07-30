package com.suvojeet.advisordesk

import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Environment
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ContentValues
import android.content.Context
import android.provider.MediaStore
import androidx.core.app.NotificationCompat
import java.io.File
import java.io.FileOutputStream

class MainActivity: FlutterActivity() {
    private val PDF_CHANNEL = "com.suvojeet.advisordesk/pdf"
    private val FEEDBACK_CHANNEL = "com.suvojeet.advisordesk/feedback"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // PDF Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PDF_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "savePdf") {
                val pdfBytes = call.argument<ByteArray>("pdfBytes")
                val fileName = call.argument<String>("fileName")
                if (pdfBytes != null && fileName != null) {
                    try {
                        val filePath = savePdfToDownloads(pdfBytes, fileName)
                        showDownloadNotification(fileName, filePath)
                        result.success("PDF saved to $filePath")
                    } catch (e: Exception) {
                        result.error("SAVE_FAILED", "Failed to save PDF.", e.toString())
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Invalid arguments for savePdf", null)
                }
            } else {
                result.notImplemented()
            }
        }

        // Feedback Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FEEDBACK_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "sendFeedback") {
                try {
                    sendFeedbackEmail()
                    result.success(null)
                } catch (e: Exception) {
                    result.error("EMAIL_FAILED", "Failed to send feedback email.", e.toString())
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun savePdfToDownloads(pdfBytes: ByteArray, fileName: String): String {
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, "application/pdf")
            put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
        }

        val resolver = context.contentResolver
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
        
        if (uri != null) {
            resolver.openOutputStream(uri).use { outputStream ->
                outputStream?.write(pdfBytes)
            }
            return uri.toString()
        } else {
            throw Exception("Failed to create new MediaStore record.")
        }
    }

    private fun showDownloadNotification(fileName: String, filePath: String) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "pdf_download_channel"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, "PDF Downloads", NotificationManager.IMPORTANCE_DEFAULT)
            notificationManager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Download Complete")
            .setContentText("$fileName has been saved to your Downloads folder.")
            .setSmallIcon(R.mipmap.ic_launcher)
            .build()

        notificationManager.notify(1, notification)
    }

    private fun sendFeedbackEmail() {
        val email = "suvojitsengupta21@gmail.com"
        val subject = "Feedback for Advisor Desk App"

        val body = """
            Feedback from Advisor Desk App
            -----------------------------------
            App Version: ${getAppVersion()}
            Device: ${Build.MANUFACTURER} ${Build.MODEL}
            Android Version: ${Build.VERSION.RELEASE}
            -----------------------------------

            Please write your feedback below:

        """.trimIndent()

        val intent = Intent(Intent.ACTION_SENDTO).apply {
            data = Uri.parse("mailto:")
            putExtra(Intent.EXTRA_EMAIL, arrayOf(email))
            putExtra(Intent.EXTRA_SUBJECT, subject)
            putExtra(Intent.EXTRA_TEXT, body)
        }

        startActivity(Intent.createChooser(intent, "Send Feedback"))
    }

    private fun getAppVersion(): String {
        return try {
            val packageInfo = context.packageManager.getPackageInfo(context.packageName, 0)
            packageInfo.versionName ?: "N/A"
        } catch (e: Exception) {
            "N/A"
        }
    }
}
