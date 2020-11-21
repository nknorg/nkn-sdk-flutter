package org.nkn.sdk

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import org.nkn.sdk.impl.Client
import org.nkn.sdk.impl.Common
import org.nkn.sdk.impl.Wallet


/** NknSdkFlutterPlugin */
class NknSdkFlutterPlugin : FlutterPlugin {
    private val common: Common = Common()
    private val wallet: Wallet = Wallet()
    private val client: Client = Client()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        common.install(flutterPluginBinding)
        wallet.install(flutterPluginBinding)
        client.install(flutterPluginBinding)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        common.uninstall()
        wallet.uninstall()
        client.uninstall()
    }
}
