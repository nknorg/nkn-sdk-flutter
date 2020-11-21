package org.nkn.sdk.impl

import android.os.AsyncTask
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import nkn.*
import org.nkn.sdk.IChannelHandler
import org.bouncycastle.util.encoders.Hex

class Client : IChannelHandler, MethodChannel.MethodCallHandler, EventChannel.StreamHandler, ViewModel() {
    private val TAG: String = this.javaClass.name
    private var clientMap: HashMap<String, MultiClient?> = hashMapOf()

    companion object {

        lateinit var methodChannel: MethodChannel
        lateinit var eventChannel: EventChannel
        var eventSink: EventChannel.EventSink? = null
        val handler: Handler = Handler(Looper.getMainLooper())
        val CHANNEL_NAME = "org.nkn.sdk/client"
        val EVENT_NAME = "org.nkn.sdk/client/event"
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
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun resultSuccess() {

    }

    private suspend fun createClient(account: Account, identifier: String, config: ClientConfig): MultiClient = withContext(Dispatchers.IO) {
        val pubKey = Hex.toHexString(account.pubKey())
        val id = if (identifier.isNullOrEmpty()) pubKey else "${identifier}.${pubKey}"
        if (clientMap.containsKey(id)) {
            closeClient(id)
        }
        val client = MultiClient(account, identifier, 3, true, config)
        clientMap[client.address()] = client
        client
    }

    private suspend fun closeClient(id: String) = withContext(Dispatchers.IO) {
        if (!clientMap.containsKey(id)) {
            return@withContext
        }
        try {
            clientMap[id]?.close()
        } catch (e: Throwable) {
            eventSink?.error(id, e.localizedMessage, "")
            return@withContext
        }
        clientMap.remove(id)
    }

    private suspend fun onConnect(client: MultiClient) = withContext(Dispatchers.IO) {
        try {
            val node = client.onConnect.next()
            val resp = hashMapOf(
                    "_id" to client.address(),
                    "event" to "onConnect",
                    "node" to hashMapOf("address" to node.addr, "publicKey" to node.pubKey),
                    "client" to hashMapOf("address" to client.address())
            )
            Log.d(TAG, resp.toString())
            handler.post {
                eventSink?.success(resp)
            }
        } catch (e: Throwable) {
            handler.post {
                eventSink?.error(client.address(), e.localizedMessage, "")
            }
        }
    }

    private suspend fun onMessage(client: MultiClient) {
        try {
            val msg = client.onMessage.next() ?: return
            val resp = hashMapOf(
                    "_id" to client.address(),
                    "event" to "onMessage",
                    "client" to hashMapOf("address" to client.address()),
                    "data" to hashMapOf(
                            "src" to msg.src,
                            "data" to String(msg.data, Charsets.UTF_8),
                            "type" to msg.type,
                            "encrypted" to msg.encrypted,
                            "messageId" to msg.messageID
                    )
            )
            Log.d(TAG, resp.toString())
            handler.post {
                eventSink?.success(resp)
            }
        } catch (e: Throwable) {
            handler.post {
                eventSink?.error(client.address(), e.localizedMessage, "")
            }
            return
        }

        onMessage(client)
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "create" -> {
                create(call, result)
            }
            "close" -> {
                close(call, result)
            }
            "sendText" -> {
                sendText(call, result)
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
        val identifier = call.argument<String>("identifier") ?: ""
        val seed = call.argument<ByteArray>("seed")
        val seedRpc = call.argument<String?>("seedRpc")

        val config = ClientConfig()
        if (seedRpc != null) {
            config.seedRPCServerAddr = StringArray(seedRpc)
        }
        val account = Nkn.newAccount(seed)

        viewModelScope.launch {
            val client = createClient(account, identifier, config)
            val data = hashMapOf(
                    "address" to client.address(),
                    "publicKey" to client.pubKey(),
                    "seed" to client.seed(),
            )
            result.success(data)
            onConnect(client)
            async(Dispatchers.IO) { onMessage(client) }
        }
    }

    private fun close(call: MethodCall, result: MethodChannel.Result) {
        val _id = call.argument<String>("_id")!!
        viewModelScope.launch {
            closeClient(_id)
            result.success(null)
        }
    }

    private fun sendText(call: MethodCall, result: MethodChannel.Result) {
        val _id = call.argument<String>("_id")!!
        val dests = call.argument<ArrayList<String>>("dests")!!
        val data = call.argument<String>("data")!!
        val maxHoldingSeconds = call.argument<Int>("maxHoldingSeconds") ?: 0
        val noReply = call.argument<Boolean>("noReply") ?: true
        val timeout = call.argument<Int>("maxHoldingSeconds") ?: 10000

        if (!clientMap.containsKey(_id)) {
            result.error("", "client is null", "")
            return
        }
        val client = clientMap[_id]

        var nknDests: StringArray? = null
        for (d in dests) {
            if (nknDests == null) {
                nknDests = Nkn.newStringArrayFromString(d)
            } else {
                nknDests.append(d)
            }
        }
        if (nknDests == null) {
            result.error("", "dests null", "")
            return
        }

        val config = MessageConfig()
        config.maxHoldingSeconds = if (maxHoldingSeconds < 0) 0 else maxHoldingSeconds
        config.messageID = Nkn.randomBytes(Nkn.MessageIDSize)
        config.noReply = noReply

        try {
            if (!noReply) {
                val onMessage = client?.sendText(nknDests, data, config)
                val msg = onMessage?.nextWithTimeout(timeout)
                if (msg == null) {
                    result.success(null)
                    return
                }
                val resp = hashMapOf(
                        "src" to msg.src,
                        "data" to String(msg.data, Charsets.UTF_8),
                        "type" to msg.type,
                        "encrypted" to msg.encrypted,
                        "messageId" to msg.messageID
                )
                result.success(resp)
                return
            } else {
                client?.sendText(nknDests, data, config)
                val resp = hashMapOf(
                        "messageId" to config.messageID
                )
                result.success(resp)
                return
            }
        } catch (e: Throwable) {
            result.error("", e.localizedMessage, e.message)
            return
        }

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
                    val resp = hashMapOf(
                            "_id" to _id,
                            "result" to balance.toDouble()
                    )
                    eventSink?.success(resp)
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
        val seed = call.argument<ByteArray>("seed")
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