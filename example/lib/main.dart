import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:nkn_sdk_flutter/client.dart';
import 'package:nkn_sdk_flutter/utils/hash.dart';
import 'package:nkn_sdk_flutter/utils/hex.dart';
import 'package:nkn_sdk_flutter/wallet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Wallet.install();
  Client.install();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Client _client1;
  Client _client2;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Text(
                'Wallet',
                style: TextStyle(fontSize: 16),
              ),
              Wrap(
                children: [
                  TextButton(
                    onPressed: () async {
                      Wallet wallet = await Wallet.create(null,
                          config: WalletConfig(password: '123'));
                      print(wallet.address);
                      print(wallet.seed);
                      print(wallet.publicKey);
                      print(wallet.keystore);
                    },
                    child: Text('create'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Wallet wallet = await Wallet.restore(
                          '{"Version":2,"IV":"d103adf904b4b2e8cca9659e88201e5d","MasterKey":"20042c80ccb809c72eb5cf4390b29b2ef0efb014b38f7229d48fb415ccf80668","SeedEncrypted":"3bcdca17d84dc7088c4b3f929cf1e96cf66c988f2b306f076fd181e04c5be187","Address":"NKNVgahGfYYxYaJdGZHZSxBg2QJpUhRH24M7","Scrypt":{"Salt":"a455be75074c2230","N":32768,"R":8,"P":1}}',
                          config: WalletConfig(password: '123'));
                      print(wallet.address);
                      print(wallet.seed);
                      print(wallet.publicKey);
                      print(wallet.keystore);
                    },
                    child: Text('restore'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Wallet wallet = await Wallet.restore(
                          '{"Version":2,"IV":"d103adf904b4b2e8cca9659e88201e5d","MasterKey":"20042c80ccb809c72eb5cf4390b29b2ef0efb014b38f7229d48fb415ccf80668","SeedEncrypted":"3bcdca17d84dc7088c4b3f929cf1e96cf66c988f2b306f076fd181e04c5be187","Address":"NKNVgahGfYYxYaJdGZHZSxBg2QJpUhRH24M7","Scrypt":{"Salt":"a455be75074c2230","N":32768,"R":8,"P":1}}',
                          config: WalletConfig(password: '123'));
                      print(await wallet.getBalance());
                    },
                    child: Text('getBalance'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Wallet wallet = await Wallet.restore(
                          '{"Version":2,"IV":"d103adf904b4b2e8cca9659e88201e5d","MasterKey":"20042c80ccb809c72eb5cf4390b29b2ef0efb014b38f7229d48fb415ccf80668","SeedEncrypted":"3bcdca17d84dc7088c4b3f929cf1e96cf66c988f2b306f076fd181e04c5be187","Address":"NKNVgahGfYYxYaJdGZHZSxBg2QJpUhRH24M7","Scrypt":{"Salt":"a455be75074c2230","N":32768,"R":8,"P":1}}',
                          config: WalletConfig(password: '123'));
                      print(await wallet.getBalance());
                      String hash = await wallet.transfer(wallet.address, '0');
                      print(hash);
                    },
                    child: Text('transfer'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Wallet wallet = await Wallet.restore(
                          '{"Version":2,"IV":"d103adf904b4b2e8cca9659e88201e5d","MasterKey":"20042c80ccb809c72eb5cf4390b29b2ef0efb014b38f7229d48fb415ccf80668","SeedEncrypted":"3bcdca17d84dc7088c4b3f929cf1e96cf66c988f2b306f076fd181e04c5be187","Address":"NKNVgahGfYYxYaJdGZHZSxBg2QJpUhRH24M7","Scrypt":{"Salt":"a455be75074c2230","N":32768,"R":8,"P":1}}',
                          config: WalletConfig(password: '123'));
                      int nonce = await wallet.getNonce();
                      print(nonce);
                    },
                    child: Text('getNonce'),
                  ),
                  TextButton(
                    onPressed: () async {
                      int height = await Wallet.getHeight();
                      print(height);
                    },
                    child: Text('getHeight'),
                  ),
                  TextButton(
                    onPressed: () async {
                      int nonce = await Wallet.getNonceByAddress(
                          'NKNVgahGfYYxYaJdGZHZSxBg2QJpUhRH24M7');
                      print(nonce);
                    },
                    child: Text('getNonceByAddress'),
                  ),
                ],
              ),
              Text(
                'Client1',
                style: TextStyle(fontSize: 16),
              ),
              Wrap(
                children: [
                  TextButton(
                    onPressed: () async {
                      Wallet wallet = await Wallet.restore(
                          '{"Version":2,"IV":"d103adf904b4b2e8cca9659e88201e5d","MasterKey":"20042c80ccb809c72eb5cf4390b29b2ef0efb014b38f7229d48fb415ccf80668","SeedEncrypted":"3bcdca17d84dc7088c4b3f929cf1e96cf66c988f2b306f076fd181e04c5be187","Address":"NKNVgahGfYYxYaJdGZHZSxBg2QJpUhRH24M7","Scrypt":{"Salt":"a455be75074c2230","N":32768,"R":8,"P":1}}',
                          config: WalletConfig(password: '123'));
                      await _client1?.close();
                      _client1 = await Client.create(wallet.seed);
                      _client1.onConnect.listen((event) {
                        print('------onConnect1-----');
                        print(event.node);
                      });
                      _client1.onMessage.listen((event) {
                        print('------onMessage1-----');
                        print(event.type);
                        print(event.encrypted);
                        print(event.messageId);
                        print(event.data);
                        print(event.src);
                      });
                    },
                    child: Text('create'),
                  ),
                  TextButton(
                    onPressed: () async {
                      _client1.close();
                    },
                    child: Text('close'),
                  ),
                  TextButton(
                    onPressed: () async {
                      var res = await _client1.sendText([_client2.address],
                          jsonEncode({'contentType': 'text', 'content': 'hi'}));
                      print(res);
                    },
                    child: Text('sendText'),
                  ),
                  TextButton(
                    onPressed: () async {
                      var res = await _client1.subscribe(
                          topic: genChannelId('ttest'));
                      print(res);
                    },
                    child: Text('subscribe'),
                  ),
                  TextButton(
                    onPressed: () async {
                      var res = await _client1.unsubscribe(
                          topic: genChannelId('ttest'));
                      print(res);
                    },
                    child: Text('unsubscribe'),
                  ),
                  TextButton(
                    onPressed: () async {
                      var res = await _client1.getSubscribersCount(
                          topic: genChannelId('ttest'));
                      print(res);
                    },
                    child: Text('getSubscribersCount'),
                  ),
                  TextButton(
                    onPressed: () async {
                      var res = await _client1.getSubscription(
                          topic: genChannelId('ttest'),
                          subscriber: _client1.address);
                      print(res);
                    },
                    child: Text('getSubscription'),
                  ),
                  TextButton(
                    onPressed: () async {
                      var res = await _client1.getSubscribers(
                          topic: genChannelId('ttest'));
                      print(res);
                    },
                    child: Text('getSubscribers'),
                  ),
                  TextButton(
                    onPressed: () async {
                      var res = await _client1.getHeight();
                      print(res);
                    },
                    child: Text('getHeight'),
                  ),
                  TextButton(
                    onPressed: () async {
                      var res = await _client1.getNonce();
                      print(res);
                    },
                    child: Text('getNonce'),
                  ),
                  TextButton(
                    onPressed: () async {
                      var res = await _client1.getNonceByAddress(
                          'NKNVgahGfYYxYaJdGZHZSxBg2QJpUhRH24M7');
                      print(res);
                    },
                    child: Text('getNonceByAddress'),
                  ),
                ],
              ),
              Text(
                'Client2',
                style: TextStyle(fontSize: 16),
              ),
              Wrap(
                children: [
                  TextButton(
                    onPressed: () async {
                      await _client2?.close();
                      _client2 = await Client.create(hexDecode(
                          'bd8bd3de4dd0f798fac5a0a56e536a8bacd5b7f46d0951d8665fd68d0a910996'));
                      _client2.onConnect.listen((event) {
                        print('------onConnect2-----');
                        print(event.node);
                      });
                      _client2.onMessage.listen((event) {
                        print('------onMessage2-----');
                        print(event.type);
                        print(event.encrypted);
                        print(event.messageId);
                        print(event.data);
                        print(event.src);
                      });
                    },
                    child: Text('create'),
                  ),
                  TextButton(
                    onPressed: () async {
                      _client2.close();
                    },
                    child: Text('close'),
                  ),
                  TextButton(
                    onPressed: () async {
                      var res = await _client2.sendText([
                        _client1.address
                      ], jsonEncode({'contentType': 'text', 'content': 'hi2'}));
                      print(res);
                    },
                    child: Text('sendText'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
