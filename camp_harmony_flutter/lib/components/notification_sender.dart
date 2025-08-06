// notification_sender.dart

import 'package:camp_harmony_app/serverpod_providers.dart';
import 'package:camp_harmony_client/camp_harmony_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSender extends ConsumerStatefulWidget {
  const NotificationSender({super.key});

  @override
  ConsumerState<NotificationSender> createState() => _NotificationSenderState();
}

class _NotificationSenderState extends ConsumerState<NotificationSender> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _messageController;
  bool _onlySendToCheckedIn = false;
  String _statusMessage = '';

  bool get _isCupertino =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onSend(Client client) async {
    if (_formKey.currentState?.validate() ?? true) {
      final title = _titleController.text.trim();
      final message = _messageController.text.trim();
      debugPrint('Sending message: "[$title]: [$message]"');
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return;
      }
      String? fbIdToken = await currentUser.getIdToken();

      if (fbIdToken == null) return;

      String result = await client.notifications
          .sendNotification(fbIdToken, title, message, _onlySendToCheckedIn);

      setState(() {
        _statusMessage = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(clientProvider);

    final content = SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque, // make sure taps “through” work
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Send Notification',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AdaptiveTextField(
                          label: 'Title',
                          controller: _titleController,
                          maxLines: 2,
                          maxLength: 50,
                          validator: (s) {
                            if (s == null || s.isEmpty) return 'Required';
                            if (s.length < 10) {
                              return 'Must be at least 10 characters';
                            }
                            return null;
                          },
                        ),
                        AdaptiveTextField(
                          label: 'Message',
                          controller: _messageController,
                          maxLines: 6,
                          maxLength: 150,
                          validator: (s) {
                            if (s == null || s.isEmpty) return 'Required';
                            if (s.length < 10) {
                              return 'Must be at least 10 characters';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Only send to "checked-in" users:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: _isCupertino
                                          ? CupertinoColors.label
                                              .resolveFrom(context)
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                              ),
                              AdaptiveSwitch(
                                  onChanged: (val) {
                                    setState(() {
                                      _onlySendToCheckedIn = val ?? false;
                                    });
                                  },
                                  value: _onlySendToCheckedIn)
                            ],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        AdaptiveButton(
                          text: 'Send',
                          onPressed: () => _onSend(client),
                        ),
                        if (_statusMessage.isNotEmpty) Text(_statusMessage)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    if (_isCupertino) {
      return CupertinoPageScaffold(
        navigationBar:
            const CupertinoNavigationBar(middle: Text('Send Notification')),
        child: content,
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Send Notification')),
        body: content,
      );
    }
  }
}

class AdaptiveTextField extends StatelessWidget {
  final String label;
  final int? maxLines;
  final int? maxLength;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const AdaptiveTextField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines,
    this.maxLength,
    this.validator,
  });

  bool get _isCupertino =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Widget build(BuildContext context) {
    if (_isCupertino) {
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          final current = value.text.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CupertinoTextFormFieldRow(
                controller: controller,
                placeholder: label,
                maxLines: maxLines,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemBackground,
                  border: Border.all(color: CupertinoColors.systemGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
                textInputAction: TextInputAction.done,
                validator: validator,
                inputFormatters: [
                  if (maxLength != null)
                    LengthLimitingTextInputFormatter(maxLength),
                ],
              ),
              if (maxLength != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 12),
                  child: Text(
                    '$current/$maxLength',
                    style: TextStyle(
                      fontSize: 12,
                      color: current >= maxLength!
                          ? CupertinoColors.systemRed.resolveFrom(context)
                          : CupertinoColors.inactiveGray,
                    ),
                  ),
                ),
            ],
          );
        },
      );
    } else {
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: [
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ],
        buildCounter: (
          BuildContext context, {
          required int currentLength,
          required int? maxLength,
          required bool isFocused,
        }) {
          if (maxLength == null) return null;
          return Text(
            '$currentLength/$maxLength',
            style: TextStyle(
              fontSize: 12,
              color: currentLength >= maxLength ? Colors.red : Colors.blueGrey,
            ),
          );
        },
        validator: validator,
      );
    }
  }
}

class AdaptiveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const AdaptiveButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  bool get _isCupertino =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Widget build(BuildContext context) {
    final child = Text(text);
    if (_isCupertino) {
      return SizedBox(
        width: double.infinity,
        child: CupertinoButton.filled(
          padding: const EdgeInsets.symmetric(vertical: 16),
          onPressed: onPressed,
          child: child,
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          child: child,
        ),
      );
    }
  }
}

class AdaptiveSwitch extends StatelessWidget {
  final ValueChanged<bool?> onChanged;
  final bool value;

  const AdaptiveSwitch({
    super.key,
    required this.onChanged,
    required this.value,
  });

  bool get _isCupertino =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Widget build(BuildContext context) {
    if (_isCupertino) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
      );
    } else {
      return Switch(
        value: value,
        onChanged: onChanged,
      );
    }
  }
}
