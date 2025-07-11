import 'dart:io';

import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter a phone number';
    final pat = r'^(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$';
    if (!RegExp(pat).hasMatch(v)) return 'Invalid US phone number';
    return null;
  }

  void _startEdit(String? currentPhone) {
    // Prefill once
    _phoneCtrl.text = currentPhone ?? '';
    setState(() => _editing = true);
  }

  void _cancelEdit(String? originalPhone) {
    // Revert and exit edit mode
    _phoneCtrl.text = originalPhone ?? '';
    setState(() => _editing = false);
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

    final success = currentlyIn
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

  Widget _buildSectionCard({required Widget child}) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Reset local UI whenever Firebase user changes
    ref.listen<AsyncValue<firebase_auth.User?>>(firebaseAuthChangesProvider,
        (_, next) {
      next.whenData((_) {
        setState(() {
          _editing = false;
          _saving = false;
          _statusMsg = '';
          _errorMsg = '';
          _phoneCtrl.clear();
        });
      });
    });

    final authState = ref.watch(firebaseAuthChangesProvider);

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Auth error: $e')),
      data: (fbUser) {
        if (fbUser == null) {
          return _buildSignInPrompt();
        }

        final uid = fbUser.uid;
        final client = ref.watch(clientProvider);
        final profile = ref.watch(userProfileProvider(uid));

        return profile.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Profile error: $e')),
          data: (user) {
            if (user == null) return _buildNoProfile();

            final isCheckedIn = user.isCheckedIn;
            final accent = Theme.of(context).colorScheme.secondary;

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade50, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 45),
                        Image.asset('images/CampHarmonyLogo.jpg', height: 275),
                        const SizedBox(height: 75),

                        // Phone section
                        _buildSectionCard(
                          child: ListTile(
                            leading: const Icon(Icons.phone),
                            title: _editing
                                ? Form(
                                    key: _formKey,
                                    child: TextFormField(
                                      controller: _phoneCtrl,
                                      keyboardType: TextInputType.phone,
                                      decoration: const InputDecoration(
                                        labelText: 'Phone Number',
                                      ),
                                      validator: _phoneValidator,
                                    ),
                                  )
                                : Text(
                                    user.phoneNumber.isNotEmpty == true
                                        ? 'Phone: ${user.phoneNumber}'
                                        : 'No phone on file',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                            trailing: _editing
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.check, color: accent),
                                        onPressed: _saving
                                            ? null
                                            : () => _savePhone(client, uid),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: _saving
                                            ? null
                                            : () =>
                                                _cancelEdit(user.phoneNumber),
                                      ),
                                    ],
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _startEdit(user.phoneNumber),
                                  ),
                          ),
                        ),

                        _buildSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Status: ${isCheckedIn ? 'Checked In' : 'Checked Out'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: isCheckedIn
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 36, vertical: 12),
                                ),
                                onPressed: _saving
                                    ? null
                                    : () => _toggleCheckIn(
                                        client, uid, isCheckedIn),
                                child: Text(
                                    isCheckedIn ? 'Check out' : 'Check in'),
                              ),
                            ],
                          ),
                        ),

                        if (_statusMsg.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              _statusMsg,
                              style: TextStyle(color: accent),
                            ),
                          ),
                        if (_errorMsg.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              _errorMsg,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),

                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: () =>
                              firebase_auth.FirebaseAuth.instance.signOut(),
                          icon: Icon(
                            Platform.isAndroid
                                ? Icons.logout
                                : CupertinoIcons.arrow_right_circle,
                          ),
                          label: const Text('Sign Out'),
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

  Widget _buildNoProfile() {
    return Center(
      child: ElevatedButton(
        onPressed: () => firebase_auth.FirebaseAuth.instance.signOut(),
        child: const Text('Log Out'),
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: ElevatedButton(
        onPressed: () => firebase_auth.FirebaseAuth.instance.signOut(),
        child: const Text('Log In'),
      ),
    );
  }
}
