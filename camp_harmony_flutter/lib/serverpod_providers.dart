import 'package:firebase_auth/firebase_auth.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientProvider = Provider<Client>((ref) {
  // Provider for the Serverpod client
  // Initialize your client here
  const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
  final serverUrl =
      serverUrlFromEnv.isEmpty ? 'http://10.0.2.2:8080/' : serverUrlFromEnv;
  return Client(serverUrl)..connectivityMonitor = FlutterConnectivityMonitor();
});

// TODO: Ensure this provider is reset on user sign out
final userProfileProvider =
    FutureProvider.autoDispose<ServerpodUser?>((ref) async {
  final client = ref.watch(clientProvider);
  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser == null) {
    return null;
  }

  final user = await client.serverpodUser.getUser(firebaseUser.uid);
  return user;
});

final onboardingCompletedProvider = StateProvider<bool>((ref) => false);

final firebaseAuthChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
