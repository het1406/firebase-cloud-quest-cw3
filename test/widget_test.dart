import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_cloud_quest_cw3/main.dart';

void main() {
  test('email and password validation reject invalid input', () {
    expect(validateEmail('bad'), isNotNull);
    expect(validateEmail('learner@example.com'), isNull);
    expect(validatePassword('12345'), isNotNull);
    expect(validatePassword('123456'), isNull);
  });
  testWidgets('registration mode and required fields are accessible', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Use at least 6 characters.'), findsOneWidget);
    await tester.tap(find.text('New here? Create account'));
    await tester.pump();
    expect(find.text('Create your account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('small screen with keyboard has no overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: 220)),
          child: AuthScreen(),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
