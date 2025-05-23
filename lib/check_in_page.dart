import 'package:flutter/material.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key, required this.title});

  final String title;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Image(image: AssetImage('images/CampHarmonyLogo.jpg')),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'First Name',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Last Name',
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          // Process data.

                          _formKey.currentState!.reset();
                          _invertCheckInStatus();
                        }
                      },
                      child: Text(_checkedIn ? 'Check out' : 'Check in'),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'You are: ${_checkedIn ? 'Checked In' : 'Checked Out'}',
            ),
          ],
        ),
      ),
    );
  }
}
