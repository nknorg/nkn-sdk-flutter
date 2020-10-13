import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nkn_sdk_flutter/nkn_sdk_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('nkn_sdk_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await NknSdkFlutter.platformVersion, '42');
  });
}
