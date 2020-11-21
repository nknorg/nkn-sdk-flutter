import 'dart:typed_data';

import 'package:convert/convert.dart';

String hexEncodeToString(Uint8List raw) {
  return hex.encode(raw).toLowerCase();
}

Uint8List hexDecode(String s) {
  return hex.decode(s);
}
