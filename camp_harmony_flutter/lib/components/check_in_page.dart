import 'dart:io';

import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../serverpod_providers.dart';

class CheckInPage extends ConsumerStatefulWidget {
  const CheckInPage({super.key});

  @override
  ConsumerState<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends ConsumerState<CheckInPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  bool _editing = false;
  bool _saving = false;
  String _statusMsg = '';
  String _errorMsg = '';

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleEdit(String? currentPhone) async {
    if (!_editing) {
      // entering edit mode: prefill
      _phoneCtrl.text = currentPhone ?? '';
    }
    setState(() => _editing = !_editing);
  }

  Future<void> _savePhone(Client client, String uid) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _statusMsg = '';
      _errorMsg = '';
    });

    try {
      final updated = await client.serverpodUser
          .updatePhoneNumber(uid, _phoneCtrl.text.trim());
      if (updated == null) throw Exception('Server returned null');

      // re-fetch userProfile (so both phone & checked-in refresh)
      ref.invalidate(userProfileProvider(uid));

      setState(() {
        _statusMsg = 'Phone number updated!';
        _editing = false;
      });
    } catch (e) {
      setState(() => _errorMsg = 'Failed to save phone: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _toggleCheckIn(
      Client client, String uid, bool currentlyIn) async {
    setState(() {
      _saving = true;
      _statusMsg = '';
      _errorMsg = '';
    });

    bool success = currentlyIn
        ? await client.checkIn.checkOut(uid)
        : await client.checkIn.checkIn(uid);

    if (success) {
      ref.invalidate(userProfileProvider(uid));
      setState(() {
        _statusMsg = currentlyIn
            ? 'Checked out successfully!'
            : 'Checked in successfully!';
      });
    } else {
      setState(() {
        _errorMsg = currentlyIn
            ? 'Check-out failed. Please try again.'
            : 'Check-in failed. Please try again.';
      });
    }

    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    // Reset when Firebase Auth state changes
    ref.listen<AsyncValue<firebase_auth.User?>>(
      firebaseAuthChangesProvider,
      (_, next) => next.whenData((_) {
        setState(() {
          _editing = false;
          _saving = false;
          _statusMsg = '';
          _errorMsg = '';
          _phoneCtrl.clear();
        });
      }),
    );

    final authState = ref.watch(firebaseAuthChangesProvider);

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Auth error: $err')),
      data: (fbUser) {
        if (fbUser == null) {
          // not signed in
          return Center(
            child: ElevatedButton(
              onPressed: () => firebase_auth.FirebaseAuth.instance.signOut(),
              child: const Text('Log In'),
            ),
          );
        }

        final uid = fbUser.uid;
        final client = ref.watch(clientProvider);
        final profile = ref.watch(userProfileProvider(uid));

        return profile.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Profile error: $err')),
          data: (user) {
            if (user == null) {
              // no profile in DB
              return Center(
                child: ElevatedButton(
                  onPressed: () =>
                      firebase_auth.FirebaseAuth.instance.signOut(),
                  child: const Text('Log Out'),
                ),
              );
            }

            final isCheckedIn = user.isCheckedIn;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      const Image(
                        image: AssetImage('images/CampHarmonyLogo.jpg'),
                      ),
                      const SizedBox(height: 24),

                      // Phone number
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _editing
                                ? TextFormField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone Number',
                                      hintText: '123-456-7890',
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Enter a phone number';
                                      }
                                      final pat =
                                          r'^\D*([2-9]\d{2})\D*(\d{3})\D*(\d{4})\D*$';
                                      if (!RegExp(pat).hasMatch(v)) {
                                        return 'Invalid US phone number';
                                      }
                                      return null;
                                    },
                                  )
                                : PlatformText(
                                    user.phoneNumber == ''
                                        ? 'No phone on file'
                                        : 'Phone: ${user.phoneNumber}',
                                  ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PlatformElevatedButton(
                                  onPressed: _saving
                                      ? null
                                      : () => _toggleEdit(user.phoneNumber),
                                  child: PlatformText(
                                      _editing ? 'Cancel' : 'Edit Phone'),
                                ),
                                const SizedBox(width: 12),
                                if (_editing)
                                  PlatformElevatedButton(
                                    onPressed: _saving
                                        ? null
                                        : () => _savePhone(client, uid),
                                    child: _saving
                                        ? const CupertinoActivityIndicator()
                                        : PlatformText('Save'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 32),

                      // Check in/out
                      PlatformElevatedButton(
                        onPressed: _saving
                            ? null
                            : () => _toggleCheckIn(client, uid, isCheckedIn),
                        child: PlatformText(
                            isCheckedIn ? 'Check out' : 'Check in'),
                      ),

                      const SizedBox(height: 12),
                      PlatformText(
                        'Status: ${isCheckedIn ? 'Checked In' : 'Checked Out'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCheckedIn ? Colors.green : Colors.red,
                        ),
                      ),

                      // Messages
                      if (_statusMsg.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        PlatformText(_statusMsg,
                            style: const TextStyle(color: Colors.orangeAccent)),
                      ],
                      if (_errorMsg.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        PlatformText(_errorMsg,
                            style: const TextStyle(color: Colors.redAccent)),
                      ],

                      const SizedBox(height: 24),

                      // Sign out
                      ElevatedButton.icon(
                        icon: Icon(
                          Platform.isAndroid
                              ? Icons.logout
                              : CupertinoIcons.arrow_right_circle,
                          size: 20,
                        ),
                        label: const Text('Sign Out'),
                        onPressed: () {
                          firebase_auth.FirebaseAuth.instance.signOut();
                          // providers will be invalidated by the listen above
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
