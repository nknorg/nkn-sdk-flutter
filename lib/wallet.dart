import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class WalletConfig {
  final String password;
  final List<String> seedRPCServerAddr;

  WalletConfig({this.password, this.seedRPCServerAddr});
}

class RpcConfig {
  final List<String> seedRPCServerAddr;

  RpcConfig({this.seedRPCServerAddr});
}

class Wallet {
  static const MethodChannel _methodChannel = MethodChannel('org.nkn.sdk/wallet');

  static install() {}

  String address;
  Uint8List seed;
  Uint8List publicKey;
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
    try {
      return await _methodChannel.invokeMethod('getBalance', {
        'address': address,
        'seedRpc': config?.seedRPCServerAddr?.isNotEmpty == true ? config.seedRPCServerAddr : null,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<double> getBalance() async {
    return getBalanceByAddr(this.address);
  }

  Future<String> transfer(String address, String amount, {String fee = '0', WalletConfig config}) async {
    try {
      return await _methodChannel.invokeMethod('transfer', {
        'seed': this.seed,
        'address': address,
        'amount': amount,
        'fee': fee,
        'seedRpc': config?.seedRPCServerAddr?.isNotEmpty == true ? config.seedRPCServerAddr : null,
      });
    } catch (e) {
      return null;
    }
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

  static Future<int> getSubscribersCount(String topic, {RpcConfig config}) async {
    try {
      int count = await _methodChannel.invokeMethod('getSubscribersCount', {
        'topic': topic,
        'seedRpc': config?.seedRPCServerAddr?.isNotEmpty == true ? config.seedRPCServerAddr : null,
      });
      return count;
    } catch (e) {
      throw e;
    }
  }

  static Future<Map<dynamic, dynamic>> getSubscription(String topic, String subscriber, {RpcConfig config}) async {
    try {
      Map<dynamic, dynamic> resp = await _methodChannel.invokeMethod('getSubscription', {
        'topic': topic,
        'subscriber': subscriber,
        'seedRpc': config?.seedRPCServerAddr?.isNotEmpty == true ? config.seedRPCServerAddr : null,
      });
      return resp;
    } catch (e) {
      throw e;
    }
  }

  static Future<Map<dynamic, dynamic>> getSubscribers({String topic, int offset = 0, int limit = 10000, bool meta = true, bool txPool = true, RpcConfig config}) async {
    try {
      Map<dynamic, dynamic> resp = await _methodChannel.invokeMethod('getSubscribers', {
        'topic': topic,
        'offset': offset,
        'limit': limit,
        'meta': meta,
        'txPool': txPool,
        'seedRpc': config?.seedRPCServerAddr?.isNotEmpty == true ? config.seedRPCServerAddr : null,
      });
      return resp;
    } catch (e) {
      throw e;
    }
  }
}
