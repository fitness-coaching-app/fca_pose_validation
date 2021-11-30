import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fca_pose_validation/fca_pose_validation.dart';

void main() {
  const MethodChannel channel = MethodChannel('fca_pose_validation');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
