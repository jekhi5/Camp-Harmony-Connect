import 'package:camp_harmony_app/components/onboarding_screen.dart';
import 'package:camp_harmony_app/serverpod_providers.dart';
import 'package:camp_harmony_app/utilities.dart';
import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerWidget {
  final Widget destinationWidget;
  final UserType requiredRole;

  const AuthGate(
      {super.key,
      required this.destinationWidget,
      this.requiredRole = UserType.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAuthStream = ref.watch(firebaseAuthChangesProvider);
    final googleOAuthClientId = dotenv.maybeGet('GOOGLE_OAUTH_CLIENT_ID');

    if (googleOAuthClientId == null) {
      if (kDebugMode) {
        print(
            'Warning: GOOGLE_OAUTH_CLIENT_ID not set in .env file, Google Sign-In will not work');
      }
    }

    final client = ref.watch(clientProvider);

    return firebaseAuthStream.when(
        data: (firebaseUser) {
          if (firebaseUser == null) {
            // Not logged in
            return SignInScreen(
              providers: [
                EmailAuthProvider(),
                GoogleProvider(clientId: googleOAuthClientId ?? ''),
              ],
              headerBuilder: (context, constraints, shrinkOffset) {
                return const Padding(
                    padding: EdgeInsets.all(20),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image(
                          image: AssetImage('images/CampHarmonyLogo.png')),
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
                      child: Image(
                          image: AssetImage('images/CampHarmonyLogo.png')),
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

                // The user types are indexed with the 'user' type being the lowest (0)
                // and higher roles have increasing indecies
                if (requiredRole.toJson() > user.role.toJson()) {
                  return Scaffold(
                    body: Center(
                      child: Text('You\'re not authorized to view this page.'),
                    ),
                  );
                }

                _registerFCMToken(client, user.id);

                return destinationWidget;
              },
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Utilities.errorLoadingUserWidget(
                  err, ref, client, firebaseUser.uid, null),
            );
          }
        },
        loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (err, stack) =>
            Utilities.errorLoadingUserWidget(err, ref, client, null, null));
  }

  void _registerFCMToken(Client client, int? userId) async {
    String? token;

    try {
      if (userId == null) {
        throw Exception("UserID can't be null when registering an FCM token");
      }

      token = await FirebaseMessaging.instance.getToken();

      if (token == null) {
        throw Exception("Token was null");
      }

      await client.notifications.registerToken(token, userId);
    } catch (e) {
      if (kDebugMode) {
        print('Error registering token: $e');
      }
    }
  }
}
