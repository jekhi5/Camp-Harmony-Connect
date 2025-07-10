import 'package:firebase_auth/firebase_auth.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientProvider = Provider<Client>((ref) {
  const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
  final serverUrl =
      serverUrlFromEnv.isEmpty ? 'http://10.0.2.2:8080/' : serverUrlFromEnv;
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
