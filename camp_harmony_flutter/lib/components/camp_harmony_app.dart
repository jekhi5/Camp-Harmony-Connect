import 'package:camp_harmony_app/components/camp_map.dart';
import 'package:camp_harmony_app/components/notification_sender.dart';
import 'package:camp_harmony_app/components/profile_page.dart';
import 'package:camp_harmony_app/serverpod_providers.dart';
import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_gate.dart';
import 'check_in_page.dart';
import 'dart:io' show Platform;

class CampHarmonyApp extends ConsumerStatefulWidget {
  const CampHarmonyApp({super.key});

  @override
  ConsumerState<CampHarmonyApp> createState() => _CampHarmonyAppState();
}

class _CampHarmonyAppState extends ConsumerState<CampHarmonyApp> {
  int _currentIndex = 0;
  bool _isAdmin = false;

  void _getAdminStatus(Client client, String? fbUID) async {
    if (fbUID == null) return;

    ServerpodUser? user = await client.serverpodUser.getUser(fbUID);

    if (user != null) {
      setState(() {
        _isAdmin = user.role == UserType.admin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final isSignedIn = snapshot.hasData;
        final fbUID = FirebaseAuth.instance.currentUser?.uid;
        final client = ref.watch(clientProvider);
        if (isSignedIn) _getAdminStatus(client, fbUID);

        final tabs = <String, BottomNavigationBarItem>{
          "checkIn": BottomNavigationBarItem(
            icon:
                Icon(Platform.isIOS ? CupertinoIcons.check_mark : Icons.check),
            label: 'Check-In',
          ),
          "map": BottomNavigationBarItem(
            icon: Icon(Platform.isIOS ? CupertinoIcons.map : Icons.map),
            label: 'Map',
          ),
          if (isSignedIn)
            "profile": BottomNavigationBarItem(
              icon: Icon(Platform.isIOS ? CupertinoIcons.person : Icons.person),
              label: 'Profile',
            ),
          if (isSignedIn && _isAdmin)
            'notifications': BottomNavigationBarItem(
              icon: Icon(Platform.isIOS
                  ? CupertinoIcons.alarm
                  : Icons.notification_add),
              label: 'Notifications',
            )
        };

        final tabDestinations = <String, Widget>{
          "checkIn": const AuthGate(destinationWidget: CheckInPage()),
          "map": const CampMap(),
          if (isSignedIn)
            "profile": const AuthGate(destinationWidget: ProfilePage()),
          if (isSignedIn && _isAdmin)
            "notifications":
                const AuthGate(destinationWidget: NotificationSender()),
        };

        final tabKeys = tabs.keys.toList();

        if (_currentIndex >= tabKeys.length) {
          _currentIndex = 0;
        }

        if (Platform.isIOS) {
          return CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              items: tabKeys.map((k) => tabs[k]!).toList(),
            ),
            tabBuilder: (context, index) {
              final key = tabKeys[index];
              return CupertinoTabView(
                builder: (context) => tabDestinations[key]!,
              );
            },
          );
        } else {
          return Scaffold(
            body: tabDestinations[tabKeys[_currentIndex]]!,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: tabKeys.map((k) => tabs[k]!).toList(),
            ),
          );
        }
      },
    );
  }
}
