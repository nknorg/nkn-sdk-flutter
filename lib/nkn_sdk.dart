import 'dart:async';

import 'package:flutter/services.dart';
import 'package:nkn_sdk_flutter/configure.dart';

class NknSdk {
  static const MethodChannel _methodChannel =
      const MethodChannel('org.nkn.sdk/common');

  // static const EventChannel _eventChannel = const EventChannel('org.nkn.sdk/common/event');

  static config({logger}) {
    if (logger != null) Configure.logger = logger;
  }
}
