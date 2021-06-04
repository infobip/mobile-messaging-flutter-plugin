import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/Configuration.dart';

void main() {
  const MethodChannel infobipChannel = MethodChannel('infobip_mobilemessaging');
  const MethodChannel packageInfoChannel = MethodChannel('dev.fluttercommunity.plus/package_info');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    packageInfoChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getAll':
          return {
            "buildNumber": '0.0.1',
            "appName": 'TestApp',
            "packageName": 'test.plugin',
            "version": '0.0.1',
          };
        default:
          return null;
      }
    });

    infobipChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'init':
          return true;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    infobipChannel.setMockMethodCallHandler(null);
    packageInfoChannel.setMockMethodCallHandler(null);
  });

  test('init', () async {
    await InfobipMobilemessaging.init(Configuration(
        applicationCode: "<Your app code>",
        androidSettings: AndroidSettings(
            firebaseSenderId: "123456"
        ),
        iosSettings: IOSSettings(
            notificationTypes: ["alert", "badge", "sound"],
            forceCleanup: false,
            logging: true
        )
    ));
  });
}