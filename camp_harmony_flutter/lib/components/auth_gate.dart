import 'package:camp_harmony_app/components/onboarding_screen.dart';
import 'package:camp_harmony_app/serverpod_providers.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerWidget {
  final Widget destinationWidget;

  const AuthGate({super.key, required this.destinationWidget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAuthStream = ref.watch(firebaseAuthChangesProvider);

    return firebaseAuthStream.when(
      data: (firebaseUser) {
        if (firebaseUser == null) {
          // Not logged in
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(clientId: dotenv.get('GOOGLE_OAUTH_CLIENT_ID')),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return const Padding(
                  padding: EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child:
                        Image(image: AssetImage('images/CampHarmonyLogo.png')),
                  ));
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text(
                        'Welcome to Camp Harmony! Please sign in before'
                        ' checking in')
                    : const Text('Welcome to Camp Harmony! Please register '
                        'before checking in'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Once signed in you\'ll be able to access personalized '
                  'resources, like your schedule',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return const Padding(
                  padding: EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child:
                        Image(image: AssetImage('images/CampHarmonyLogo.png')),
                  ));
            },
          );
        } else {
          // Logged in, check for ServerPod data
          final userProfileAsyncValue =
              ref.watch(userProfileProvider(firebaseUser.uid));

          return userProfileAsyncValue.when(
            data: (user) {
              if (user == null) {
                // User has not completed onboarding, show onboarding screen
                return OnboardingScreen();
              }

              return destinationWidget;
            },
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: Text('Error loading user data: $err')),
                  ElevatedButton(
                    onPressed: () {
                      // Retry loading user data
                      ref.invalidate(userProfileProvider(firebaseUser.uid));
                      ref.invalidate(firebaseAuthChangesProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: Text('Firebase Auth error: $err')),
            ElevatedButton(
              onPressed: () {
                // Retry loading user data
                ref.invalidate(userProfileProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
