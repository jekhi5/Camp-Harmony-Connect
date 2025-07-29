import 'dart:io';

import 'package:camp_harmony_app/serverpod_providers.dart';
import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Utilities {
  static String? phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter a phone number';
    final pat = r'^(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$';
    if (!RegExp(pat).hasMatch(v)) return 'Invalid US phone number';
    return null;
  }

  static String? nameValidator(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Cannot be empty';
    } else if (v.trim().length >= 50) {
      return 'Must be at most 50 characters';
    } else {
      return null;
    }
  }

  static Widget signOutButton(WidgetRef ref, Client client, int? userId) {
    void signOutLogic() async {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await client.notifications.deregisterToken(token, userId);
      }
      await FirebaseAuth.instance.signOut().whenComplete(() {
        ref.invalidate(userProfileProvider);
      });
    }

    return Platform.isIOS
        ? CupertinoButton(
            onPressed: signOutLogic,
            child: const Text('Sign Out'),
          )
        : ElevatedButton(
            onPressed: signOutLogic,
            child: const Text('Sign Out'),
          );
  }

  static Widget errorLoadingUserWidget(
      Object err, WidgetRef ref, Client client, String? fbUID, int? userId) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Text('Error loading user data: $err')),
          ElevatedButton(
            onPressed: () {
              // Retry loading user data
              if (fbUID != null) ref.invalidate(userProfileProvider(fbUID));
              ref.invalidate(firebaseAuthChangesProvider);
            },
            child: const Text('Retry'),
          ),
          const SizedBox(height: 16),
          signOutButton(ref, client, userId)
        ],
      ),
    );
  }
}
