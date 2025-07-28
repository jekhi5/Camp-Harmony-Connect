import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientProvider = Provider<Client>((ref) {
  final mode = dotenv.get('MODE');
  String serverUrlFromEnv;
  if (mode == 'development') {
    serverUrlFromEnv = Platform.isIOS
        ? dotenv.get('IOS_SERVER_URL')
        : dotenv.get('ANDROID_SERVER_URL');
  } else {
    serverUrlFromEnv = 'https://camp-harmony-app-server.onrender.com/';
  }

  final String serverUrl = serverUrlFromEnv.isNotEmpty
      ? serverUrlFromEnv
      : throw Exception(
          'Environment variable for server is not set. Please set it in your environment.');

  return Client(serverUrl)..connectivityMonitor = FlutterConnectivityMonitor();
});

final userProfileProvider =
    FutureProvider.autoDispose.family<ServerpodUser?, String>((ref, uid) async {
  final client = ref.watch(clientProvider);
  return await client.serverpodUser.getUser(uid);
});

final firebaseAuthChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
