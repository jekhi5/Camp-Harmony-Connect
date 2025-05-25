import 'package:camp_harmony_app/camp_map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'check_in_page.dart';
import 'dart:io' show Platform;

class CampHarmonyApp extends StatefulWidget {
  const CampHarmonyApp({super.key});

  @override
  State<CampHarmonyApp> createState() => _CampHarmonyAppState();
}

class _CampHarmonyAppState extends State<CampHarmonyApp> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const CheckInPage(),
    const CampMap(),
  ];

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person), label: 'Check-In'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.map), label: 'Map'),
          ],
        ),
        tabBuilder: (context, index) => CupertinoTabView(
          builder: (context) => _tabs[index],
        ),
      );
    } else {
      return Scaffold(
        body: _tabs[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Check-In'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          ],
        ),
      );
    }
  }
}
