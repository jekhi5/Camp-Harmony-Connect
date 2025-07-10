import 'dart:io';

import 'package:camp_harmony_app/components/auth_gate.dart';
import 'package:camp_harmony_app/serverpod_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'check_in_page.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.read(clientProvider);
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Authentication session expired. Please sign in again.')),
          );
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (ctx) => AuthGate(destinationWidget: CheckInPage())));
        }
      });
      return const Scaffold(body: Center(child: Text('Redirecting...')));
    }

    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Welcome! Let\'s get to know you')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            SizedBox(height: 16),
            Text(
              // TODO: Identify what should happen if email is null
              'Email: ${firebaseUser.email ?? 'No email provided'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final newUser = ServerpodUser(
                  firebaseUID: firebaseUser.uid,
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  email: firebaseUser.email ?? '',
                  phoneNumber: phoneNumberController.text,
                  registrationDate: DateTime.now(),
                  isActive: true,
                  roles: ['user'],
                );

                await client.serverpodUser.addUser(newUser);

                ref.invalidate(userProfileProvider(firebaseUser.uid));
              },
              child: Text('Complete Onboarding'),
            ),
            Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton.icon(
                    icon: Icon(
                        Platform.isAndroid
                            ? Icons.logout
                            : CupertinoIcons.arrow_right_circle,
                        size: 20),
                    label: const Text('Sign Out'),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut().whenComplete(() {
                        ref.invalidate(userProfileProvider);
                      });
                    })),
          ],
        ),
      ),
    );
  }
}
