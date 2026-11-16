import 'dart:async';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

/// Uses the same authenticated callable protocol in both environments.
/// Direct emulator transport avoids the Android SDK requesting an optional
/// Firebase Installations/FCM token from production for a demo project.
Future<Map<String, dynamic>> callQuest(
  String name,
  Map<String, dynamic> data,
) async {
  const emulated = bool.fromEnvironment('USE_EMULATORS', defaultValue: true);
  if (!emulated) {
    final result = await FirebaseFunctions.instance
        .httpsCallable(name)
        .call(data);
    return Map<String, dynamic>.from(result.data as Map);
  }
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw FirebaseException(plugin: 'cloud_functions', code: 'unauthenticated');
  }
  const host = String.fromEnvironment(
    'EMULATOR_HOST',
    defaultValue: '10.0.2.2',
  );
  final project = Firebase.app().options.projectId;
  final token = await user.getIdToken();
  try {
    final response = await http
        .post(
          Uri.parse('http://$host:5001/$project/us-central1/$name'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'data': data}),
        )
        .timeout(const Duration(seconds: 45));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['error'] is Map) {
      final error = body['error'] as Map;
      throw FirebaseException(
        plugin: 'cloud_functions',
        code: (error['status'] as String? ?? 'INTERNAL')
            .toLowerCase()
            .replaceAll('_', '-'),
        message: error['message'] as String?,
      );
    }
    if (response.statusCode != 200 || body['result'] is! Map) {
      throw FirebaseException(plugin: 'cloud_functions', code: 'internal');
    }
    return Map<String, dynamic>.from(body['result'] as Map);
  } on TimeoutException {
    throw FirebaseException(plugin: 'cloud_functions', code: 'unavailable');
  } on http.ClientException {
    throw FirebaseException(plugin: 'cloud_functions', code: 'unavailable');
  }
}
