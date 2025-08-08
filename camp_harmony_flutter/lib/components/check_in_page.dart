import 'dart:io';

import 'package:camp_harmony_app/utilities.dart';
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

  bool _saving = false;
  String _statusMsg = '';
  String _errorMsg = '';

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleCheckIn(
      Client client, String firebaseUID, bool currentlyIn) async {
    setState(() {
      _saving = true;
      _statusMsg = '';
      _errorMsg = '';
    });

    final success = currentlyIn
        ? await client.checkIn.checkOut(firebaseUID)
        : await client.checkIn.checkIn(firebaseUID);

    if (success) {
      ref.invalidate(userProfileProvider(firebaseUID));
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
    // reset UI when auth changes
    ref.listen<AsyncValue<firebase_auth.User?>>(firebaseAuthChangesProvider,
        (_, next) {
      next.whenData((_) {
        setState(() {
          _saving = false;
          _statusMsg = '';
          _errorMsg = '';
          _phoneCtrl.clear();
        });
      });
    });

    final authState = ref.watch(firebaseAuthChangesProvider);
    final client = ref.watch(clientProvider);

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Utilities.errorLoadingUserWidget(e, ref, client, null, null),
      data: (fbUser) {
        if (fbUser == null) return Utilities.signOutButton(ref, client, null);

        final fbUID = fbUser.uid;
        final profile = ref.watch(userProfileProvider(fbUID));

        return profile.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Utilities.errorLoadingUserWidget(e, ref, client, fbUID, null),
          data: (user) {
            if (user == null) return Utilities.signOutButton(ref, client, null);

            return Platform.isIOS
                ? _buildCupertinoPage(context, user, client)
                : _buildMaterialPage(context, user, client, fbUID);
          },
        );
      },
    );
  }

  Widget _buildMaterialPage(
      BuildContext context, ServerpodUser user, Client client, String uid) {
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
                Image.asset('images/CampHarmonyLogo.png', height: 275),
                const SizedBox(height: 75),

                // Phone section
                _buildSectionCard(
                  child: ListTile(
                    // leading: const Icon(Icons.phone),
                    title: Text(
                      user.phoneNumber.isNotEmpty
                          ? user.phoneNumber
                          : 'No phone on file',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),

                // Check-In section
                _buildSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Status: ${isCheckedIn ? 'On camp grounds' : 'Not on camp grounds'}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                              color: isCheckedIn ? Colors.green : Colors.red,
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
                            : () => _toggleCheckIn(client, uid, isCheckedIn),
                        child: Text(isCheckedIn ? 'Check out' : 'Check in'),
                      ),
                    ],
                  ),
                ),

                if (_statusMsg.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(_statusMsg, style: TextStyle(color: accent)),
                  ),
                if (_errorMsg.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(_errorMsg,
                        style: const TextStyle(color: Colors.red)),
                  ),

                const SizedBox(height: 24),
                Utilities.signOutButton(ref, client, user.id),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoPage(
      BuildContext context, ServerpodUser user, Client client) {
    final isCheckedIn = user.isCheckedIn;
    final accent = CupertinoTheme.of(context).primaryColor;
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final placeholderColor =
        CupertinoColors.placeholderText.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Check In'),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              // Logo
              Center(
                  child:
                      Image.asset('images/CampHarmonyLogo.png', height: 100)),
              const SizedBox(height: 24),

              // Phone section
              CupertinoListSection.insetGrouped(
                header:
                    Text('Phone Number', style: TextStyle(color: labelColor)),
                children: [
                  CupertinoListTile(
                    title: Text(
                        user.phoneNumber.isNotEmpty
                            ? user.phoneNumber
                            : 'No phone on file',
                        style: TextStyle(color: placeholderColor)),
                  ),
                ],
              ),

              // Check-In section
              CupertinoListSection.insetGrouped(
                header: Text('Attendance', style: TextStyle(color: labelColor)),
                children: [
                  CupertinoListTile(
                    title: Text(
                      isCheckedIn ? 'On camp grounds' : 'Not on camp grounds',
                      style: TextStyle(
                        color: isCheckedIn
                            ? CupertinoColors.activeGreen
                            : CupertinoColors.systemRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoListTile(
                      title: const Text(''),
                      trailing: CupertinoButton.filled(
                        onPressed: () => _toggleCheckIn(
                            client, user.firebaseUID, isCheckedIn),
                        child: Text(isCheckedIn ? 'Check out' : 'Check in'),
                      ),
                    ),
                  ),
                ],
              ),

              if (_statusMsg.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(_statusMsg,
                      style: TextStyle(color: accent),
                      textAlign: TextAlign.center),
                ),
              if (_errorMsg.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(_errorMsg,
                      style: const TextStyle(color: CupertinoColors.systemRed),
                      textAlign: TextAlign.center),
                ),

              // Sign-out
              const SizedBox(height: 24),
              Utilities.signOutButton(ref, client, user.id),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
