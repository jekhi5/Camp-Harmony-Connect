import 'dart:io';

import 'package:camp_harmony_app/components/auth_gate.dart';
import 'package:camp_harmony_app/serverpod_providers.dart';
import 'package:camp_harmony_app/utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'check_in_page.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});
  static final TextEditingController _firstNameController =
      TextEditingController();
  static final TextEditingController _lastNameController =
      TextEditingController();
  static final TextEditingController _phoneNumberController =
      TextEditingController();
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submitOnboarding(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    final client = ref.read(clientProvider);

    final newUser = ServerpodUser(
      firebaseUID: firebaseUser!.uid,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: firebaseUser.email ?? '',
      phoneNumber: _phoneNumberController.text,
      registrationDate: DateTime.now(),
      isCheckedIn: false,
      roles: ['user'],
    );

    await client.serverpodUser.addUser(newUser);

    ref.invalidate(userProfileProvider(firebaseUser.uid));
  }

  CupertinoListTile _buildCupertinoListTile(
      BuildContext context,
      String fieldTitle,
      TextEditingController controller,
      TextInputType keyboardType,
      String? Function(String?)? validator) {
    final labelColor = CupertinoColors.label.resolveFrom(context);
    const double kWidth = 150;

    return CupertinoListTile(
        title: Text(fieldTitle, style: TextStyle(color: labelColor)),
        trailing: SizedBox(
          width: kWidth,
          child: CupertinoTextFormFieldRow(
            controller: controller,
            textAlign: TextAlign.right,
            textDirection: TextDirection.ltr,
            style: TextStyle(color: labelColor),
            keyboardType: keyboardType,
            placeholder: fieldTitle,
            placeholderStyle: TextStyle(color: labelColor.withOpacity(0.5)),
            validator: validator,
          ),
        ));
  }

  Widget _buildCupertino(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Welcome! Let\'s get to know you'),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: ListView(
                children: [
                  CupertinoListSection.insetGrouped(
                      header: Text(
                        'Welcome! Let\'s get to know you',
                        style: TextStyle(
                            color: CupertinoColors.label.resolveFrom(context)),
                      ),
                      children: [
                        _buildCupertinoListTile(
                            context,
                            'First Name',
                            _firstNameController,
                            TextInputType.text,
                            Utilities.nameValidator),
                        _buildCupertinoListTile(
                            context,
                            'Last Name',
                            _lastNameController,
                            TextInputType.text,
                            Utilities.nameValidator),
                        _buildCupertinoListTile(
                            context,
                            'Phone Number',
                            _phoneNumberController,
                            TextInputType.phone,
                            Utilities.phoneValidator),
                      ]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CupertinoButton.filled(
                      child: Text('Complete Onboarding'),
                      onPressed: () => _submitOnboarding(ref),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: CupertinoButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.arrow_right_circle, size: 20),
                          SizedBox(width: 8),
                          Text('Sign Out'),
                        ],
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut().whenComplete(() {
                          ref.invalidate(userProfileProvider);
                        });
                      },
                    ),
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMaterialFormField(
      BuildContext context,
      String fieldTitle,
      TextEditingController controller,
      TextInputType keyboardType,
      String? Function(String?)? validator) {
    return [
      Text(fieldTitle, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 4),
      TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: validator,
      )
    ];
  }

  Widget _buildMaterial(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome! Let\'s get to know you')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._buildMaterialFormField(
                  context,
                  'First Name',
                  _firstNameController,
                  TextInputType.text,
                  Utilities.nameValidator),
              const SizedBox(height: 12),
              ..._buildMaterialFormField(
                  context,
                  'Last Name',
                  _lastNameController,
                  TextInputType.text,
                  Utilities.nameValidator),
              const SizedBox(height: 12),
              ..._buildMaterialFormField(
                  context,
                  'Phone Number',
                  _phoneNumberController,
                  TextInputType.phone,
                  Utilities.phoneValidator),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _submitOnboarding(ref),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Platform.isIOS
        ? _buildCupertino(context, ref)
        : _buildMaterial(context, ref);
  }
}
