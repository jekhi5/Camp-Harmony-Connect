// server/lib/src/services/fcm_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class FcmService {
  Future<String> _getAccessToken() async {
    final raw = Platform.environment['FIREBASE_SERVICE_ACCOUNT_JSON']!;
    final account = json.decode(raw) as Map<String, dynamic>;
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(account),
      ['https://www.googleapis.com/auth/firebase.messaging'],
    );
    return client.credentials.accessToken.data;
  }

  Future<bool> sendNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final raw = Platform.environment['FIREBASE_SERVICE_ACCOUNT_JSON']!;
    final proj = (json.decode(raw) as Map<String, dynamic>)['project_id'];
    final url =
        Uri.parse('https://fcm.googleapis.com/v1/projects/$proj/messages:send');
    final headers = {
      HttpHeaders.authorizationHeader: 'Bearer ${await _getAccessToken()}',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    final message = {
      'message': {
        'token': token,
        'notification': {'title': title, 'body': body},
        if (data != null) 'data': data,
        'android': {
          'notification': {'click_action': 'FLUTTER_NOTIFICATION_CLICK'}
        },
        'apns': {
          'payload': {
            'aps': {'content-available': 1}
          }
        },
      },
    };
    final resp =
        await http.post(url, headers: headers, body: json.encode(message));
    return resp.statusCode == 200;
  }
}
