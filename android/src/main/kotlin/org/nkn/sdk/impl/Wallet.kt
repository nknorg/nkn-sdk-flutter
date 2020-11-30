package org.nkn.sdk.impl

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.nkn.sdk.IChannelHandler
import nkn.Nkn
import nkn.StringArray
import nkn.TransactionConfig
import nkn.WalletConfig
import org.bouncycastle.util.encoders.Hex

class Wallet : IChannelHandler, MethodChannel.MethodCallHandler, EventChannel.StreamHandler, ViewModel() {

    companion object {
        lateinit var methodChannel: MethodChannel
        var eventSink: EventChannel.EventSink? = null
        val CHANNEL_NAME = "org.nkn.sdk/wallet"
    }

    override fun install(binaryMessenger: BinaryMessenger) {
        methodChannel = MethodChannel(binaryMessenger, CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)
    }

    override fun uninstall() {
        methodChannel.setMethodCallHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
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
        val password = call.argument<String>("password") ?: ""
        val seed = if (seedHex != null) Hex.decode(seedHex) else Nkn.randomBytes(32)
        val account = Nkn.newAccount(seed)
        val config = WalletConfig()
        config.password = password
        val wallet = Nkn.newWallet(account, config)
        val json = wallet.toJSON()
        val resp = hashMapOf(
                "address" to wallet.address(),
                "keystore" to json,
                "publicKey" to wallet.pubKey(),
                "seed" to wallet.seed()
        )
        result.success(resp)
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
        val resp = hashMapOf(
                "address" to wallet.address(),
                "keystore" to json,
                "publicKey" to wallet.pubKey(),
                "seed" to wallet.seed()
        )
        result.success(resp)
    }

    private fun pubKeyToWalletAddr(call: MethodCall, result: MethodChannel.Result) {
        val pubkey = call.argument<String>("publicKey")

        val addr = Nkn.pubKeyToWalletAddr(Hex.decode(pubkey))
        result.success(addr)
    }

    private fun getBalance(call: MethodCall, result: MethodChannel.Result) {
        val address = call.argument<String>("address")
        val seedRpc = call.argument<String?>("seedRpc")
        val account = Nkn.newAccount(Nkn.randomBytes(32))

        val config = WalletConfig()
        if (seedRpc != null) {
            config.seedRPCServerAddr = StringArray(seedRpc)
        }
        val wallet = Nkn.newWallet(account, config)
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val balance = wallet.balanceByAddress(address).toString()
                resultSuccess(result, balance.toDouble())
                return@launch
            } catch (e: Throwable) {
                resultError(result, e)
                return@launch
            }
        }
    }

    private fun transfer(call: MethodCall, result: MethodChannel.Result) {
        val seed = call.argument<ByteArray>("seed")
        val address = call.argument<String>("address")
        val amount = call.argument<String>("amount") ?: "0"
        val fee = call.argument<String>("fee") ?: "0"
        val seedRpc = call.argument<String?>("seedRpc")
        val config = WalletConfig()
        if (seedRpc != null) {
            config.seedRPCServerAddr = StringArray(seedRpc)
        }
        viewModelScope.launch(Dispatchers.IO) {
            try {
                val account = Nkn.newAccount(seed)
                val wallet = Nkn.newWallet(account, config)
                val transactionConfig = TransactionConfig()
                transactionConfig.fee = fee
                val hash = wallet.transfer(address, amount, transactionConfig)
                resultSuccess(result, hash)
                return@launch
            } catch (e: Throwable) {
                resultError(result, e)
                return@launch
            }
        }
    }
}