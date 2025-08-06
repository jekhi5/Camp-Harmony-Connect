import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'package:serverpod/serverpod.dart';

/// Service for sending Firebase Cloud Messages (FCM)
class FcmService {
  var env = DotEnv(includePlatformEnvironment: true)..load();

  /// Get an access token for Firebase service account
  /// This token is used to authenticate requests to the FCM API.
  /// Throws an exception if the service account JSON is not found in the environment.
  /// The service account JSON should be stored in the environment variable `FIREBASE_SERVICE_ACCOUNT_JSON`.
  /// Returns the access token as a string.
  Future<String> _getAccessToken(Session session) async {
    final raw = env['FIREBASE_SERVICE_ACCOUNT_JSON'];
    if (raw == null) {
      session.log("ERROR: `FIREBASE_SERVICE_ACCOUNT_JSON` not present in env");
      throw Exception("FIREBASE_SERVICE_ACCOUNT_JSON not present in env");
    }
    final account = json.decode(raw) as Map<String, dynamic>;
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(account),
      ['https://www.googleapis.com/auth/firebase.messaging'],
    );
    return client.credentials.accessToken.data;
  }

  /// Send a notification to a specific device using its FCM token.
  /// The [session] is implied, but the following variables are required:
  /// The [token] is the FCM token of the device to send the notification to.
  /// The [title] is the title of the notification.
  /// The [body] is the body of the notification.
  /// The [data] is an optional map of additional data to include in the notification.
  /// Returns true if the notification was sent successfully, otherwise returns false.
  Future<bool> sendNotification({
    required Session session,
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final raw = env['FIREBASE_SERVICE_ACCOUNT_JSON'];
    if (raw == null) {
      session.log(
          "ERROR: `FIREBASE_SERVICE_ACCOUNT_JSON` not found in environment");
      return false;
    }
    final proj = (json.decode(raw) as Map<String, dynamic>)['project_id'];
    final url =
        Uri.parse('https://fcm.googleapis.com/v1/projects/$proj/messages:send');
    final headers = {
      HttpHeaders.authorizationHeader:
          'Bearer ${await _getAccessToken(session)}',
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
