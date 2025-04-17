import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:digitalbank/pages/index.dart';
import 'package:digitalbank/public/variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String server = serverURL;

  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String loginMsg = "";
  bool _obscurePassword = true;

  void _togglePassword() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  Future<void> _login() async {
    // Validate inputs first
    if (_username.text.isEmpty || _password.text.isEmpty) {
      await _showErrorDialog('Please enter both username and password');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$server/api/accounts/login.php'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'username': _username.text.trim(),
          'password': _password.text.trim()
        }),
      ).timeout(const Duration(seconds: 10));

      debugPrint('Response Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Navigate to home screen
        Navigator.push(context, CupertinoPageRoute(builder: (context) => Indexpage()));
      } else {
        // Show specific error from server
        final errorMsg = responseData['message'] ?? 'Login failed';
        await _showErrorDialog(errorMsg);
      }
    } on SocketException {
      await _showErrorDialog('No internet connection');
    } on TimeoutException {
      await _showErrorDialog('Connection timeout');
    } on http.ClientException {
      await _showErrorDialog('Server connection failed');
    } catch (e) {
      debugPrint('Login error: $e');
      await _showErrorDialog('An unexpected error occurred');
    }
  }

  Future<void> _showErrorDialog(String message) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Login Failed'),
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

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                CupertinoTextField(
                  controller: _username,
                  placeholder: "Username",
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),

                CupertinoTextField(
                  controller: _password,
                  placeholder: "Password",
                  obscureText: _obscurePassword,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffix: GestureDetector(
                    onTap: _togglePassword,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        _obscurePassword
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text(
                      "Forgot your password?",
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    child: const Text("LOGIN"),
                    onPressed: _login,
                  ),
                ),

                const SizedBox(height: 24),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
