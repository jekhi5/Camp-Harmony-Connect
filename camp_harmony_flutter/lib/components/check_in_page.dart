import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
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
  CheckInStatus? checkInStatus;
  bool _checkedIn = false;
  String errorMessage = '';
  String statusMessage = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _invertCheckInStatus(Client client) async {
    try {
      final CheckInStatus? checkInStatus =
          await client.checkIn.checkIn(0); // Replace 0 with actual user ID

      if (checkInStatus != null) {
        setState(() {
          _checkedIn = checkInStatus.checkedIn;
          this.checkInStatus = checkInStatus;
          errorMessage = '';
          statusMessage = checkInStatus.statusMessage ??
              'Did not receive a status message.';
        });
      } else {
        setState(() {
          errorMessage = 'Check-in failed. Please try again.';
        });
      }
    } catch (e) {
      // Handle error
      print('Error checking in: $e');
      setState(() {
        errorMessage = 'Check-in failed. Please try again.';
      });
    }
  }

  MaterialTextFormFieldData getMatFormField(String labelText, IconData icon) {
    return MaterialTextFormFieldData(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
    );
  }

  CupertinoTextFormFieldData getCupertinoFormField(
      String placeholder, IconData icon) {
    return CupertinoTextFormFieldData(
      placeholder: placeholder,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      prefix: Icon(icon, size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    PlatformElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.reset();
                          _invertCheckInStatus(client);
                        }
                      },
                      child:
                          PlatformText(_checkedIn ? 'Check out' : 'Check in'),
                    ),
                    const SizedBox(height: 24),
                    PlatformText(
                      'You are: ${_checkedIn ? 'Checked In' : 'Checked Out'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _checkedIn ? Colors.green : Colors.red,
                      ),
                    ),
                    const Padding(
                        padding: EdgeInsets.all(20), child: SignOutButton()),
                    PlatformText(
                      statusMessage,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
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
  }
}
