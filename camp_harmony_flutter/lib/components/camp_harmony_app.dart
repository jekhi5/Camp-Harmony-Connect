import 'package:camp_harmony_app/components/camp_map.dart';
import 'package:camp_harmony_client/camp_harmony_client.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'check_in_page.dart';
import 'dart:io' show Platform;

class CampHarmonyApp extends StatefulWidget {
  const CampHarmonyApp({super.key});

  @override
  State<CampHarmonyApp> createState() => _CampHarmonyAppState();
}

class _CampHarmonyAppState extends State<CampHarmonyApp> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final isSignedIn = snapshot.hasData;
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
        };

        final tabDestinations = <String, Widget>{
          "checkIn": const AuthGate(destinationWidget: CheckInPage()),
          "map": const CampMap(),
          if (isSignedIn)
            "profile": const AuthGate(destinationWidget: ProfileScreen()),
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
