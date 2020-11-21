import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class Message {
  Uint8List messageId;
  String src;
  Map data;
  int type;
  bool encrypted;

  Message({this.messageId, this.data, this.src, this.type, this.encrypted});
}

class ClientConfig {
  final List<String> seedRPCServerAddr;

  ClientConfig({this.seedRPCServerAddr});
}

class Client {
  static const MethodChannel _methodChannel = MethodChannel('org.nkn.sdk/client');
  static const EventChannel _eventChannel = EventChannel('org.nkn.sdk/client/event');
  static Map<String, Completer> _clientEventQueue = Map<String, Completer>();

  static install() {
    _eventChannel.receiveBroadcastStream().listen((res) {
      final String event = res['event'].toString();

      // Map data = event;
      // String key = data['_id'];
      // var result;
      // if (data.containsKey('result')) {
      //   result = data['result'];
      // } else {
      //   var keys = data.keys.toList();
      //   keys.remove('_id');
      //   result = Map<String, dynamic>();
      //   for (var key in keys) {
      //     result[key] = data[key];
      //   }
      // }

      // _clientEventQueue[key].complete(result);
    }, onError: (err) {
      if (_clientEventQueue[err.code] != null) {
        _clientEventQueue[err.code].completeError(err.message);
      }
    });
  }

  String address;
  Uint8List seed;
  Uint8List publicKey;

  ClientConfig clientConfig;

  Client({this.clientConfig});

  static Future<Client> create(Uint8List seed, {String identifier = '', ClientConfig config}) async {
    try {
      final Map resp = await _methodChannel.invokeMethod('create', {
        'identifier': identifier,
        'seed': seed,
        'seedRpc': config?.seedRPCServerAddr?.isNotEmpty == true ? config.seedRPCServerAddr : null,
      });
      Client client = Client();
      client.address = resp['address'];
      client.publicKey = resp['publicKey'];
      client.seed = resp['seed'];
      return client;
    } catch (e) {
      throw e;
    }
  }

  Future<void> close() async {
    await _methodChannel.invokeMethod('close', {'_id': this.address});
  }

  Future<Message> sendText(List<String> dests, String data, {int maxHoldingSeconds = 8640000, noReply = true}) async {
    try {
      final Map resp = await _methodChannel.invokeMethod('sendText', {
        '_id': this.address,
        'dests': dests,
        'data': data,
        'noReply': noReply,
        'maxHoldingSeconds': maxHoldingSeconds,
      });
      Message message = Message(
        messageId: resp['messageId'],
        data: resp['data'],
        type: resp['type'],
        encrypted: resp['encrypted'],
        src: resp['src'],
      );
      return message;
    } catch (e) {
      throw e;
    }
  }
}
