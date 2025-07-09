import 'package:camp_harmony_app/components/auth_gate.dart';
import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
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

  void _phoneNumberOnPress() {
    if (_editingPhoneNumber) {
      // Save the phone number
      _userPhoneNumber = _phoneNumberController.text.trim();
      if (_userPhoneNumber!.isEmpty) {
        setState(() {
          _errorMessage = "Please enter a valid phone number.";
        });
        return;
      }
      // TODO: Actually save phone number in DB
      setState(() {
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

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return AuthGate(destinationWidget: CheckInPage());
    }
    final Client client = ref.watch(clientProvider);

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
                        )),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: _editingPhoneNumber
                          ? PlatformTextField(
                              textAlign: TextAlign.center,
                              keyboardType:
                                  const TextInputType.numberWithOptions(),
                              readOnly: !_editingPhoneNumber,
                              hintText: "Phone Number",
                              controller: _phoneNumberController,
                            )
                          : PlatformText(
                              _userPhoneNumber == null
                                  ? "No Phone Number Found"
                                  : "Phone Number: $_userPhoneNumber",
                            ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: PlatformElevatedButton(
                            onPressed: () {
                              _phoneNumberOnPress();
                            },
                            child: PlatformText(_editingPhoneNumber
                                ? "Save"
                                : "Edit Phone Number"))),
                    PlatformElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.reset();
                          _checkInOut(client);
                        }
                      },
                      child: PlatformText(
                          _checkedIn == true ? 'Check out' : 'Check in'),
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
                        color: _checkedIn == true ? Colors.green : Colors.red,
                      ),
                    ),
                    const Padding(
                        padding: EdgeInsets.all(10), child: SignOutButton()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
