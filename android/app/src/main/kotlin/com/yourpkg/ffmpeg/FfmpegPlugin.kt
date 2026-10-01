package com.yourpkg.ffmpeg

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FfmpegPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private val runner = FfmpegRunner()

    companion object {
        const val METHOD_CHANNEL_NAME = "com.motioncut.pro/ffmpeg"
        const val EVENT_CHANNEL_NAME = "com.motioncut.pro/ffmpeg_progress"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "executeFFmpeg" -> {
                val args = call.argument<List<String>>("arguments")
                if (args == null) {
                    result.error("INVALID_ARGS", "FFmpeg arguments list is required", null)
                    return
                }

                runner.execute(
                    arguments = args,
                    onProgress = { line -> eventSink?.success(line) },
                    onComplete = { success -> result.success(success) }
                )
            }
            "cancelFFmpeg" -> {
                runner.cancel()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}
