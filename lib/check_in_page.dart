import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  bool _checkedIn = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _invertCheckInStatus() {
    setState(() {
      _checkedIn = !_checkedIn;
    });
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
                    PlatformTextFormField(
                      material: (_, __) =>
                          getMatFormField("First Name", Icons.person),
                      cupertino: (_, __) => getCupertinoFormField(
                          "First Name", CupertinoIcons.person),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    PlatformTextFormField(
                      material: (_, __) =>
                          getMatFormField("Last Name", Icons.person),
                      cupertino: (_, __) => getCupertinoFormField(
                          "Last Name", CupertinoIcons.person),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    PlatformElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.reset();
                          _invertCheckInStatus();
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
