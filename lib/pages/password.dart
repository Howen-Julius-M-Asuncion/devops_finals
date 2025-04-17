import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../public/variables.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isComplete = false;

  Future<void> _resetPassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$serverURL/api/accounts/reset.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': resetEmail,
          'new_password': _newPasswordController.text,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        _showSuccessDialog('Password reset successfully!', () {
          Navigator.popUntil(context, (route) => route.isFirst);
        });
      } else {
        _showErrorDialog(data['error'] ?? 'Failed to reset password');
        print(resetEmail);
      }
    } catch (e) {
      _showErrorDialog('Connection error');
      print(resetEmail);
    }

    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message, VoidCallback onPressed) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Change Password"),
      ),
      child: SafeArea(
        child: Center(
          child: _isLoading
              ? const CupertinoActivityIndicator(radius: 20)
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 1),
                Text(
                  'Create a new password',
                  style: CupertinoTheme.of(context)
                      .textTheme
                      .textStyle
                      .copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CupertinoTextField(
                  controller: _newPasswordController,
                  placeholder: 'New Password',
                  obscureText: _obscureNewPassword,
                  padding: const EdgeInsets.all(16),
                  suffix: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() => _obscureNewPassword = !_obscureNewPassword);
                    },
                    child: Icon(
                      _obscureNewPassword
                          ? CupertinoIcons.eye
                          : CupertinoIcons.eye_slash,
                      size: 20,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isComplete = value.isNotEmpty &&
                          _confirmPasswordController.text.isNotEmpty;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: _confirmPasswordController,
                  placeholder: 'Confirm Password',
                  obscureText: _obscureConfirmPassword,
                  padding: const EdgeInsets.all(16),
                  suffix: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                    child: Icon(
                      _obscureConfirmPassword
                          ? CupertinoIcons.eye
                          : CupertinoIcons.eye_slash,
                      size: 20,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isComplete = value.isNotEmpty &&
                          _newPasswordController.text.isNotEmpty;
                    });
                  },
                ),
                const SizedBox(height: 32),
                CupertinoButton.filled(
                  child: const Text('Reset Password'),
                  onPressed: _isComplete ? _resetPassword : null,
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}