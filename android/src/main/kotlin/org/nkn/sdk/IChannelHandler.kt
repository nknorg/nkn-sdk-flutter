package org.nkn.sdk

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin

interface IChannelHandler {
    fun install(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding)
    fun uninstall()
}