import 'dart:io';

import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../serverpod_providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _editing = false;
  bool _saving = false;
  String _statusMessage = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(Client client, String uid) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _statusMessage = '';
      _errorMessage = '';
    });

    try {
      final updated = await client.serverpodUser.updateProfile(
        uid,
        _firstNameCtrl.text.trim(),
        _lastNameCtrl.text.trim(),
        _phoneCtrl.text.trim(),
      );

      if (updated == null) throw Exception('Server returned null');

      ref.invalidate(userProfileProvider(uid));

      setState(() {
        _statusMessage = 'Profile updated successfully!';
        _editing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save: $e';
      });
    } finally {
      setState(() => _saving = false);
    }
  }

  void _toggleEdit() {
    setState(() {
      _editing = !_editing;
      _statusMessage = '';
      _errorMessage = '';
      // If cancelling, reset controllers back to last-known values:
      if (!_editing) {
        final user = ref
            .read(userProfileProvider(
              ref.read(firebaseAuthChangesProvider).value!.uid,
            ))
            .value;
        if (user != null) {
          _firstNameCtrl.text = user.firstName;
          _lastNameCtrl.text = user.lastName;
          _phoneCtrl.text = user.phoneNumber;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(firebaseAuthChangesProvider);

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Auth error: $e')),
      data: (fbUser) {
        if (fbUser == null) {
          return Center(child: Text('Not signed in'));
        }

        final uid = fbUser.uid;
        final client = ref.watch(clientProvider);
        final profile = ref.watch(userProfileProvider(uid));

        return profile.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading profile: $e')),
          data: (user) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo or header if you like:
                      const SizedBox(height: 24),

                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // First Name
                            Text(
                              'First Name',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            _editing
                                ? PlatformTextField(
                                    controller: _firstNameCtrl,
                                    material: (_, __) => MaterialTextFieldData(
                                      decoration: const InputDecoration(),
                                    ),
                                  )
                                : PlatformText(user!.firstName),

                            const SizedBox(height: 16),

                            // Last Name
                            Text(
                              'Last Name',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            _editing
                                ? PlatformTextField(
                                    controller: _lastNameCtrl,
                                    material: (_, __) => MaterialTextFieldData(
                                      decoration: const InputDecoration(),
                                    ),
                                  )
                                : PlatformText(user!.lastName),

                            const SizedBox(height: 16),

                            // Phone Number
                            Text(
                              'Phone Number',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            _editing
                                ? PlatformTextField(
                                    controller: _phoneCtrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(),
                                    material: (_, __) => MaterialTextFieldData(
                                      decoration: const InputDecoration(
                                        hintText: '123-456-7890',
                                      ),
                                    ),
                                  )
                                : PlatformText(user!.phoneNumber),

                            const SizedBox(height: 16),

                            // Email (always read-only)
                            Text(
                              'Email',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            PlatformText(user!.email),

                            const SizedBox(height: 24),

                            // Edit / Cancel toggle
                            PlatformElevatedButton(
                              onPressed: _saving
                                  ? null
                                  : () {
                                      if (!_editing) {
                                        // we're about to enter editing mode:
                                        _firstNameCtrl.text = user.firstName;
                                        _lastNameCtrl.text = user.lastName;
                                        _phoneCtrl.text = user.phoneNumber;
                                      } else {
                                        // we're cancelling edit, reset back to last-known values:
                                        _firstNameCtrl.text = user.firstName;
                                        _lastNameCtrl.text = user.lastName;
                                        _phoneCtrl.text = user.phoneNumber;
                                      }
                                      setState(() {
                                        _editing = !_editing;
                                        _statusMessage = '';
                                        _errorMessage = '';
                                      });
                                    },
                              child: PlatformText(
                                  _editing ? 'Cancel' : 'Edit Profile'),
                            ),

                            const SizedBox(height: 8),

                            // Save button (only while editing)
                            if (_editing)
                              PlatformElevatedButton(
                                onPressed: _saving
                                    ? null
                                    : () => _saveProfile(client, uid),
                                child: _saving
                                    ? const CupertinoActivityIndicator()
                                    : PlatformText('Save Changes'),
                              ),

                            const SizedBox(height: 12),

                            // Status & error
                            if (_statusMessage.isNotEmpty)
                              PlatformText(
                                _statusMessage,
                                style: const TextStyle(color: Colors.green),
                              ),
                            if (_errorMessage.isNotEmpty)
                              PlatformText(
                                _errorMessage,
                                style: const TextStyle(color: Colors.red),
                              ),

                            const SizedBox(height: 24),

                            // Sign Out
                            ElevatedButton.icon(
                              icon: Icon(
                                Platform.isAndroid
                                    ? Icons.logout
                                    : CupertinoIcons.arrow_right_circle,
                                size: 20,
                              ),
                              label: const Text('Sign Out'),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                ref.invalidate(userProfileProvider(uid));
                                ref.invalidate(firebaseAuthChangesProvider);
                              },
                            ),
                          ],
                        ),
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
