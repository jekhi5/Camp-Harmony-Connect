import 'dart:io';

import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _startEdit(ServerpodUser user) {
    _firstNameCtrl.text = user.firstName;
    _lastNameCtrl.text = user.lastName;
    _phoneCtrl.text = user.phoneNumber;
    setState(() => _editing = true);
  }

  void _cancelEdit() {
    setState(() => _editing = false);
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
      setState(() => _errorMessage = 'Failed to save: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  String? _notEmptyValidator(String? v) {
    return (v == null || v.trim().isEmpty) ? 'Cannot be empty' : null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<firebase_auth.User?>>(firebaseAuthChangesProvider,
        (_, next) {
      next.whenData((_) {
        setState(() {
          _editing = false;
          _saving = false;
          _statusMessage = '';
          _errorMessage = '';
        });
      });
    });

    final auth = ref.watch(firebaseAuthChangesProvider);
    return auth.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Auth error: $e')),
      data: (fbUser) {
        if (fbUser == null) {
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
          error: (e, _) => Center(child: Text('Error loading profile: \$e')),
          data: (user) {
            if (user == null) {
              return Center(
                child: ElevatedButton(
                  onPressed: () =>
                      firebase_auth.FirebaseAuth.instance.signOut(),
                  child: const Text('Log Out'),
                ),
              );
            }

            final accent = Theme.of(context).colorScheme.primary;

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Image.asset('images/CampHarmonyLogo.jpg', height: 100),
                        const SizedBox(height: 16),

                        Card(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(
                                  'Profile',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                trailing: _editing
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.check,
                                                color: accent),
                                            onPressed: _saving
                                                ? null
                                                : () =>
                                                    _saveProfile(client, uid),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed:
                                                _saving ? null : _cancelEdit,
                                          ),
                                        ],
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _startEdit(user),
                                      ),
                              ),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // First Name
                                      Text('First Name',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge),
                                      const SizedBox(height: 4),
                                      _editing
                                          ? TextFormField(
                                              controller: _firstNameCtrl,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                              ),
                                              validator: _notEmptyValidator,
                                            )
                                          : Text(user.firstName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                      const SizedBox(height: 12),

                                      // Last Name
                                      Text('Last Name',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge),
                                      const SizedBox(height: 4),
                                      _editing
                                          ? TextFormField(
                                              controller: _lastNameCtrl,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                              ),
                                              validator: _notEmptyValidator,
                                            )
                                          : Text(user.lastName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                      const SizedBox(height: 12),

                                      // Phone Number
                                      Text('Phone Number',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge),
                                      const SizedBox(height: 4),
                                      _editing
                                          ? TextFormField(
                                              controller: _phoneCtrl,
                                              keyboardType: TextInputType.phone,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                              ),
                                              validator: (v) =>
                                                  v == null || v.trim().isEmpty
                                                      ? 'Enter phone'
                                                      : null,
                                            )
                                          : Text(user.phoneNumber,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                      const SizedBox(height: 12),

                                      // Email (read-only)
                                      Text('Email',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge),
                                      const SizedBox(height: 4),
                                      Text(user.email,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Status or error
                        if (_statusMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(_statusMessage,
                                style: TextStyle(color: accent)),
                          ),
                        if (_errorMessage.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Failed to save changes',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Sign out
                        TextButton.icon(
                          icon: Icon(
                            Platform.isAndroid
                                ? Icons.logout
                                : CupertinoIcons.arrow_right_circle,
                          ),
                          label: const Text('Sign Out'),
                          onPressed: () =>
                              firebase_auth.FirebaseAuth.instance.signOut(),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
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
