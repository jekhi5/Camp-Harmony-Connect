import 'dart:io';

import 'package:camp_harmony_app/utilities.dart';
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

  @override
  Widget build(BuildContext context) {
    // Listen for auth changes to reset editing state
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
      error: (e, _) => Utilities.errorLoadingUserWidget(e, ref, null),
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
          error: (e, _) => Utilities.errorLoadingUserWidget(e, ref, uid),
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

            final isIOS = Platform.isIOS;
            return isIOS
                ? _buildCupertinoPage(context, user, client, uid)
                : _buildMaterialPage(context, user, client, uid);
          },
        );
      },
    );
  }

  Widget _buildMaterialPage(
      BuildContext context, ServerpodUser user, Client client, String uid) {
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
                Image.asset('images/CampHarmonyLogo.png', height: 100),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          'Hi ${user.firstName}!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        trailing: _editing
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check, color: accent),
                                    onPressed: _saving
                                        ? null
                                        : () => _saveProfile(client, uid),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: _saving ? null : _cancelEdit,
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ..._buildMaterialFormField(
                                  context,
                                  _editing,
                                  user.firstName,
                                  'First Name',
                                  _firstNameCtrl,
                                  TextInputType.text,
                                  Utilities.nameValidator),
                              const SizedBox(height: 12),
                              ..._buildMaterialFormField(
                                  context,
                                  _editing,
                                  user.lastName,
                                  'Last Name',
                                  _lastNameCtrl,
                                  TextInputType.text,
                                  Utilities.nameValidator),
                              const SizedBox(height: 12),
                              ..._buildMaterialFormField(
                                  context,
                                  _editing,
                                  user.phoneNumber,
                                  'Phone Number',
                                  _phoneCtrl,
                                  TextInputType.phone,
                                  Utilities.phoneValidator),
                              const SizedBox(height: 12),
                              Text('Email',
                                  style:
                                      Theme.of(context).textTheme.labelLarge),
                              const SizedBox(height: 4),
                              Text(user.email,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_statusMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child:
                        Text(_statusMessage, style: TextStyle(color: accent)),
                  ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Failed to save changes: $_errorMessage',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.primary,
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
  }

  List<Widget> _buildMaterialFormField(
      BuildContext context,
      bool editing,
      String userValue,
      String fieldTitle,
      TextEditingController controller,
      TextInputType keyboardType,
      String? Function(String?)? validator) {
    return [
      Text(fieldTitle, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 4),
      _editing
          ? TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              keyboardType: keyboardType,
              validator: validator,
            )
          : Text(userValue, style: Theme.of(context).textTheme.bodyMedium)
    ];
  }

  CupertinoListTile _buildCupertinoListTile(
      BuildContext context,
      bool editing,
      String userValue,
      String fieldTitle,
      TextEditingController controller,
      TextInputType keyboardType,
      String? Function(String?)? validator) {
    final labelColor = CupertinoColors.label.resolveFrom(context);
    const double kWidth = 180;

    return CupertinoListTile(
        title: Text(fieldTitle, style: TextStyle(color: labelColor)),
        trailing: SizedBox(
          width: kWidth,
          child: _editing
              ? CupertinoTextFormFieldRow(
                  controller: controller,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: labelColor),
                  keyboardType: keyboardType,
                  placeholder: userValue,
                  placeholderStyle:
                      TextStyle(color: labelColor.withOpacity(0.5)),
                  validator: validator,
                )
              : Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        userValue,
                        style: TextStyle(
                          color: CupertinoColors.label.resolveFrom(context),
                        ),
                      )),
                ),
        ));
  }

  Widget _buildCupertinoPage(
    BuildContext context,
    ServerpodUser user,
    Client client,
    String uid,
  ) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    final labelColor = CupertinoColors.label.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: _editing
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _cancelEdit,
                child: const Text('Cancel'),
              )
            : null,
        middle: Text(_editing ? 'Edit Profile' : 'Profile'),
        trailing: _editing
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saving ? null : () => _saveProfile(client, uid),
                child: const Text('Save'),
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('Edit',
                    style: TextStyle(color: primaryColor, fontSize: 16)),
                onPressed: () => _startEdit(user),
              ),
      ),
      child: SafeArea(
        child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // Profile fields
                      CupertinoListSection.insetGrouped(
                        header: Text(
                          'Hi ${user.firstName}!',
                          style: TextStyle(color: labelColor),
                        ),
                        children: [
                          _buildCupertinoListTile(
                              context,
                              _editing,
                              user.firstName,
                              'First Name',
                              _firstNameCtrl,
                              TextInputType.text,
                              Utilities.nameValidator),
                          _buildCupertinoListTile(
                              context,
                              _editing,
                              user.lastName,
                              'Last Name',
                              _lastNameCtrl,
                              TextInputType.text,
                              Utilities.nameValidator),
                          _buildCupertinoListTile(
                              context,
                              _editing,
                              user.phoneNumber,
                              'Phone Number',
                              _phoneCtrl,
                              TextInputType.phone,
                              Utilities.phoneValidator),
                          CupertinoListTile(
                            title: Text(
                              'Email',
                              style: TextStyle(color: labelColor),
                            ),
                            trailing: Text(user.email,
                                style: TextStyle(
                                    color: CupertinoColors.inactiveGray)),
                          ),
                        ],
                      ),

                      // Status messages
                      if (_statusMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            _statusMessage,
                            style: TextStyle(color: primaryColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: CupertinoButton.filled(
                          onPressed: () =>
                              firebase_auth.FirebaseAuth.instance.signOut(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(CupertinoIcons.square_arrow_right),
                              SizedBox(width: 8),
                              Text('Sign Out'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
