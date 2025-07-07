import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientProvider = Provider<Client>((ref) {
  // Provider for the Serverpod client
  // Initialize your client here
  const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
  final serverUrl =
      serverUrlFromEnv.isEmpty ? 'ADD YOUR SERVER URL HERE' : serverUrlFromEnv;
  return Client(serverUrl)..connectivityMonitor = FlutterConnectivityMonitor();
});
