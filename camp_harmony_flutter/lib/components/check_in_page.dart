import 'dart:io';

import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
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
  CheckInStatus? _checkInStatus;
  bool? _checkedIn = false;
  String _errorMessage = '';
  String _statusMessage = '';
  bool _editingPhoneNumber = false;
  String? _userPhoneNumber;
  final TextEditingController _phoneNumberController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  void _checkInOut(Client client) async {
    try {
      if (_userPhoneNumber == null) {
        setState(() {
          _errorMessage = "Please enter a valid phone number to check in!";
        });
        return;
      }

      _checkInStatus =
          await client.checkIn.checkIn(0); // Replace 0 with actual user ID

      if (_checkInStatus != null) {
        setState(() {
          _checkedIn = _checkInStatus?.checkedIn;
          _checkInStatus = _checkInStatus;
          _errorMessage = '';
          _statusMessage = _checkInStatus?.statusMessage ??
              'Did not receive a status message.';
        });
      } else {
        setState(() {
          _errorMessage = 'Check-in failed. Please try again.';
        });
      }
    } catch (e) {
      // Handle error
      print('Error checking in: $e');
      setState(() {
        _errorMessage = 'Check-in failed. Please try again.';
      });
    }
  }

  void _toggleEditingPhoneNumber() {
    setState(() {
      _editingPhoneNumber = !_editingPhoneNumber;
    });
  }

  void _phoneNumberOnPress(Client client, String uid) async {
    if (_editingPhoneNumber) {
      if (!_formKey.currentState!.validate()) return;
      String phoneNumber = _phoneNumberController.text.trim();
      if (phoneNumber.isEmpty) {
        setState(() {
          _errorMessage = "Please enter a valid phone number.";
        });
        return;
      }

      _userPhoneNumber = phoneNumber;

      var user = await client.serverpodUser.updatePhoneNumber(uid, phoneNumber);
      ref.invalidate(userProfileProvider(uid));

      setState(() {
        if (user == null) {
          _errorMessage = "Failed to update phone number. Please try again.";
          return;
        }
        _statusMessage = "Phone number updated successfully.";
        _errorMessage = '';
      });
    } else {
      // Start editing phone number
      _phoneNumberController.text = _userPhoneNumber ?? '';
    }
    _toggleEditingPhoneNumber();
  }

  // Clear the phone number controller when the widget is disposed
  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  Widget _buildCheckInForm(Client client, String firebaseUID) {
    final userAsync = ref.watch(userProfileProvider(firebaseUID));

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading profile: $err')),
      data: (user) {
        // Pre-populate the controller when not editing
        if (!_editingPhoneNumber) {
          _phoneNumberController.text = user?.phoneNumber ?? '';
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Image(image: AssetImage('images/CampHarmonyLogo.jpg')),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Welcome to Camp Harmony! Please check in below:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: _editingPhoneNumber
                              ? TextFormField(
                                  controller: _phoneNumberController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    hintText: '123-456-7890',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a phone number';
                                    }

                                    final pattern =
                                        r'^\D*([2-9]\d{2})\D*(\d{3})\D*(\d{4})\D*$';
                                    final regExp = RegExp(pattern);
                                    if (!regExp.hasMatch(value)) {
                                      return 'Enter a valid 10-digit US phone number';
                                    }
                                    return null;
                                  },
                                )
                              : PlatformText(
                                  user?.phoneNumber == null
                                      ? "No Phone Number Found"
                                      : "Phone Number: ${user!.phoneNumber}",
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: PlatformElevatedButton(
                            onPressed: () =>
                                _phoneNumberOnPress(client, firebaseUID),
                            child: PlatformText(
                              _editingPhoneNumber
                                  ? "Save"
                                  : "Edit Phone Number",
                            ),
                          ),
                        ),
                        if (!_editingPhoneNumber)
                          PlatformElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.reset();
                                _checkInOut(client);
                              }
                            },
                            child: PlatformText(
                              _checkedIn == true ? 'Check out' : 'Check in',
                            ),
                          ),
                        const SizedBox(height: 10),
                        PlatformText(
                          _statusMessage,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        PlatformText(
                          _errorMessage,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        PlatformText(
                          'You are: ${_checkedIn == true ? 'Checked In' : 'Checked Out'}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                _checkedIn == true ? Colors.green : Colors.red,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Platform.isAndroid
                                  ? Icons.logout
                                  : CupertinoIcons.arrow_right_circle,
                              size: 20,
                            ),
                            label: const Text('Sign Out'),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              ref.invalidate(userProfileProvider(firebaseUID));
                              ref.invalidate(firebaseAuthChangesProvider);
                            },
                          ),
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
  }

  Widget _showSignInError() {
    return Column(
      children: [
        Text('Authentication Error, please log in again.'),
        ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut().whenComplete(() {
              ref.invalidate(userProfileProvider);
              ref.invalidate(firebaseAuthChangesProvider);
            });
          },
          child: const Text('Log In'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      // Redirect to a separate login or landing page to avoid infinite loop
      return _showSignInError();
    }
    final Client client = ref.watch(clientProvider);
    final firebaseAuthStream = ref.watch(firebaseAuthChangesProvider);

    return firebaseAuthStream.when(
      data: (firebaseUser) {
        if (firebaseUser == null) {
          return _showSignInError();
        } else {
          return _buildCheckInForm(client, firebaseUser.uid);
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          children: [
            PlatformText('Error: $error'),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(firebaseAuthChangesProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
