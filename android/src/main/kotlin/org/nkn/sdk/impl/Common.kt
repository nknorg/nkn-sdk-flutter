package org.nkn.sdk.impl

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.nkn.sdk.IChannelHandler


class Common : IChannelHandler, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        lateinit var channel: MethodChannel
        var eventSink: EventChannel.EventSink? = null
        lateinit var handler: Handler
        val CHANNEL_NAME = "org.nkn.sdk/common"
        val EVENT_NAME = "org.nkn.sdk/common/event"
    }

    override fun install(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun uninstall() {
        channel.setMethodCallHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        handler = Handler(Looper.getMainLooper())
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "configure" -> {
                configure(call, result)
            }
            "installWalletPlugin" -> {
                installWalletPlugin(call, result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun configure(call: MethodCall, result: MethodChannel.Result) {

        result.success(null)

        handler.post {

//            eventSink?.success(data)
        }
    }

    private fun installWalletPlugin(call: MethodCall, result: MethodChannel.Result) {

        result.success(null)

    }

}