import 'package:camp_harmony_app/components/auth_gate.dart';
import 'package:camp_harmony_app/serverpod_providers.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'check_in_page.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.read(clientProvider);
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      // If no Firebase user is logged in, redirect to the sign-in screen
      return AuthGate(destinationWidget: CheckInPage());
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
                // Save user data to Serverpod
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

                // Implement your Serverpod endpoint to create or update the user
                await client.serverpodUser.addUser(newUser);

                ref.read(onboardingCompletedProvider.notifier).state = true;
              },
              child: Text('Complete Onboarding'),
            ),
            const Padding(padding: EdgeInsets.all(10), child: SignOutButton()),
          ],
        ),
      ),
    );
  }
}
