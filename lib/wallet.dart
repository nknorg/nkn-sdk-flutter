import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class WalletConfig {
  final String password;
  final List<String> seedRPCServerAddr;

  WalletConfig({this.password, this.seedRPCServerAddr});
}

class Wallet {
  static const MethodChannel _methodChannel = MethodChannel('org.nkn.sdk/wallet');
  static const EventChannel _eventChannel = EventChannel('org.nkn.sdk/wallet/event');
  static Map<String, Completer> _walletEventQueue = Map<String, Completer>();

  static install() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      Map data = event;
      String key = data['_id'];
      var result;
      if (data.containsKey('result')) {
        result = data['result'];
      } else {
        var keys = data.keys.toList();
        keys.remove('_id');
        result = Map<String, dynamic>();
        for (var key in keys) {
          result[key] = data[key];
        }
      }

      _walletEventQueue[key].complete(result);
    }, onError: (err) {
      if (_walletEventQueue[err.code] != null) {
        _walletEventQueue[err.code].completeError(err.message);
      }
    });
  }

  String address;
  String seed;
  String publicKey;
  String keystore;

  WalletConfig walletConfig;

  Wallet({this.walletConfig});

  static Future<Wallet> create(String seed, String password) async {
    try {
      final Map data = await _methodChannel.invokeMethod('create', {
        'seed': seed,
        'password': password,
      });
      Wallet wallet = Wallet();
      wallet.keystore = data['keystore'];
      wallet.address = data['address'];
      wallet.seed = data['seed'];
      wallet.publicKey = data['publicKey'];
      return wallet;
    } catch (e) {
      throw e;
    }
  }

  static Future<Wallet> restore(String keystore, String password) async {
    try {
      final Map data = await _methodChannel.invokeMethod('restore', {
        'keystore': keystore,
        'password': password,
      });
      Wallet wallet = Wallet();
      wallet.keystore = data['keystore'];
      wallet.address = data['address'];
      wallet.seed = data['seed'];
      wallet.publicKey = data['publicKey'];
      return wallet;
    } catch (e) {
      throw e;
    }
  }

  static Future<double> getBalanceByAddr(String address, {WalletConfig config}) async {
    Completer<double> completer = Completer<double>();
    String id = completer.hashCode.toString();
    _walletEventQueue[id] = completer;
    _methodChannel.invokeMethod('getBalance', {
      '_id': id,
      'address': address,
      'seedRpc': config?.seedRPCServerAddr?.isNotEmpty == true ? config.seedRPCServerAddr : null,
    });

    return completer.future.whenComplete(() {
      _walletEventQueue.remove(id);
    });
  }

  Future<double> getBalance() async {
    return await getBalanceByAddr(this.address);
  }

  Future<String> transfer(String address, String amount, {String fee ='0',WalletConfig config}) async {
    Completer<String> completer = Completer<String>();
    String id = completer.hashCode.toString();
    _walletEventQueue[id] = completer;
    _methodChannel.invokeMethod('transfer', {
      '_id': id,
      'seed': this.seed,
      'address': address,
      'amount': amount,
      'fee': fee,
      'seedRpc': config?.seedRPCServerAddr?.isNotEmpty == true ? config.seedRPCServerAddr : null,
    });
    return completer.future.whenComplete(() {
      _walletEventQueue.remove(id);
    });
  }

  static Future<String> pubKeyToWalletAddr(String publicKey) async {
    try {
      final String address = await _methodChannel.invokeMethod('pubKeyToWalletAddr', {
        'publicKey': publicKey,
      });
      return address;
    } catch (e) {
      return null;
    }
  }
}
