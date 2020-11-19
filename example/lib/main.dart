import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:nkn_sdk_flutter/nkn_sdk.dart';
import 'package:nkn_sdk_flutter/wallet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Wallet.install();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
                  FlatButton(
                    onPressed: ()async {
                      Wallet wallet = await Wallet.create(null, '123');
                      print(wallet.address);
                      print(wallet.seed);
                      print(wallet.publicKey);
                      print(wallet.keystore);
                    },
                    child: Text('create'),
                  ),
                  FlatButton(
                    onPressed: ()async {
                      Wallet wallet = await Wallet.restore('{"Version":2,"IV":"d103adf904b4b2e8cca9659e88201e5d","MasterKey":"20042c80ccb809c72eb5cf4390b29b2ef0efb014b38f7229d48fb415ccf80668","SeedEncrypted":"3bcdca17d84dc7088c4b3f929cf1e96cf66c988f2b306f076fd181e04c5be187","Address":"NKNVgahGfYYxYaJdGZHZSxBg2QJpUhRH24M7","Scrypt":{"Salt":"a455be75074c2230","N":32768,"R":8,"P":1}}', '123');
                      print(wallet.address);
                      print(wallet.seed);
                      print(wallet.publicKey);
                      print(wallet.keystore);
                    },
                    child: Text('restore'),
                  ),
                  FlatButton(
                    onPressed: ()async {
                      Wallet wallet = await Wallet.restore('{"Version":2,"IV":"d103adf904b4b2e8cca9659e88201e5d","MasterKey":"20042c80ccb809c72eb5cf4390b29b2ef0efb014b38f7229d48fb415ccf80668","SeedEncrypted":"3bcdca17d84dc7088c4b3f929cf1e96cf66c988f2b306f076fd181e04c5be187","Address":"NKNVgahGfYYxYaJdGZHZSxBg2QJpUhRH24M7","Scrypt":{"Salt":"a455be75074c2230","N":32768,"R":8,"P":1}}', '123');
                      print(await wallet.getBalance());
                    },
                    child: Text('getBalance'),
                  ),
                  FlatButton(
                    onPressed: ()async {
                      Wallet wallet = await Wallet.restore('{"Version":2,"IV":"d103adf904b4b2e8cca9659e88201e5d","MasterKey":"20042c80ccb809c72eb5cf4390b29b2ef0efb014b38f7229d48fb415ccf80668","SeedEncrypted":"3bcdca17d84dc7088c4b3f929cf1e96cf66c988f2b306f076fd181e04c5be187","Address":"NKNVgahGfYYxYaJdGZHZSxBg2QJpUhRH24M7","Scrypt":{"Salt":"a455be75074c2230","N":32768,"R":8,"P":1}}', '123');
                      print(await wallet.getBalance());
                      String hash = await wallet.transfer('NKNVCZYpUk94xe3p3miNGSoQnkidQUfPMQxx', '0.01');
                      print(hash);
                    },
                    child: Text('transfer'),
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
