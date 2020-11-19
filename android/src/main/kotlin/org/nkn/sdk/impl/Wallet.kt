package org.nkn.sdk.impl

import android.os.AsyncTask
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.nkn.sdk.IChannelHandler
import nkn.Nkn
import nkn.StringArray
import nkn.TransactionConfig
import nkn.WalletConfig
import org.bouncycastle.util.encoders.Hex

class Wallet : IChannelHandler, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        lateinit var methodChannel: MethodChannel
        lateinit var eventChannel: EventChannel
        var eventSink: EventChannel.EventSink? = null
        lateinit var handler: Handler
        val CHANNEL_NAME = "org.nkn.sdk/wallet"
        val EVENT_NAME = "org.nkn.sdk/wallet/event"
    }

    override fun install(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_NAME)
        eventChannel.setStreamHandler(this)
    }

    override fun uninstall() {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
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
            "create" -> {
                create(call, result)
            }
            "restore" -> {
                restore(call, result)
            }
            "pubKeyToWalletAddr" -> {
                pubKeyToWalletAddr(call, result)
            }
            "getBalance" -> {
                getBalance(call, result)
            }
            "transfer" -> {
                transfer(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun create(call: MethodCall, result: MethodChannel.Result) {
        val seedHex = call.argument<String>("seed")
        val password = call.argument<String>("password")
        val seed = if (seedHex != null) Hex.decode(seedHex) else Nkn.randomBytes(32)
        val account = Nkn.newAccount(seed)
        val config = WalletConfig()
        config.password = password
        val wallet = Nkn.newWallet(account, config)
        val json = wallet.toJSON()
        val data = hashMapOf(
                "address" to wallet.address(),
                "keystore" to json,
                "publicKey" to Hex.toHexString(wallet.pubKey()),
                "seed" to Hex.toHexString(wallet.seed())
        )
        result.success(data)
    }

    private fun restore(call: MethodCall, result: MethodChannel.Result) {
        val keystore = call.argument<String>("keystore")
        val password = call.argument<String>("password") ?: ""
        if (keystore == null) {
            result.success(null)
            return
        }
        val config = WalletConfig()
        config.password = password
        val wallet = Nkn.walletFromJSON(keystore, config)
        val json = wallet?.toJSON()
        val data = hashMapOf(
                "address" to wallet.address(),
                "keystore" to json,
                "publicKey" to Hex.toHexString(wallet.pubKey()),
                "seed" to Hex.toHexString(wallet.seed())
        )
        result.success(data)
    }

    private fun pubKeyToWalletAddr(call: MethodCall, result: MethodChannel.Result) {
        val pubkey = call.argument<String>("publicKey")

        val addr = Nkn.pubKeyToWalletAddr(Hex.decode(pubkey))
        result.success(addr)
    }

    private fun getBalance(call: MethodCall, result: MethodChannel.Result) {
        val _id = call.argument<String>("_id")
        val address = call.argument<String>("address")
        val seedRpc = call.argument<String?>("seedRpc")
        val account = Nkn.newAccount(Nkn.randomBytes(32))
        result.success(null)
        val config = WalletConfig()
        if (seedRpc != null) {
            config.seedRPCServerAddr = StringArray(seedRpc)
        }
        val wallet = Nkn.newWallet(account, config)
        AsyncTask.SERIAL_EXECUTOR.execute {
            try {
                val balance = wallet.balanceByAddress(address).toString()
                handler.post {
                    val data = hashMapOf(
                            "_id" to _id,
                            "result" to balance.toDouble()
                    )
                    eventSink?.success(data)
                }
            } catch (e: Exception) {
                handler.post {
                    eventSink?.error(_id, e.localizedMessage, "")
                }

            }
        }
    }

    private fun transfer(call: MethodCall, result: MethodChannel.Result) {
        val _id = call.argument<String>("_id")
        val seedHex = call.argument<String>("seed")
        val address = call.argument<String>("address")
        val amount = call.argument<String>("amount") ?: "0"
        val fee = call.argument<String>("fee") ?: "0"
        val seedRpc = call.argument<String?>("seedRpc")
        result.success(null)
        val config = WalletConfig()
        if (seedRpc != null) {
            config.seedRPCServerAddr = StringArray(seedRpc)
        }
        AsyncTask.SERIAL_EXECUTOR.execute {
            try {
                val seed = if (seedHex != null) Hex.decode(seedHex) else Nkn.randomBytes(32)
                val account = Nkn.newAccount(seed)
                val wallet = Nkn.newWallet(account, config)
                val transactionConfig = TransactionConfig()
                transactionConfig.fee = fee
                val hash = wallet.transfer(address, amount, transactionConfig)
                handler.post {
                    val hash = hashMapOf(
                            "_id" to _id,
                            "result" to hash
                    )
                    eventSink?.success(hash)
                }
            } catch (e: Exception) {
                handler.post {
                    eventSink?.error(_id, e.localizedMessage, "")
                }

            }
        }
    }
}