import 'dart:async';
import 'dart:convert';
import 'package:digitalbank/pages/password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../public/variables.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({super.key});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final _otpController = TextEditingController();
  String email = resetEmail;
  bool isComplete = false;
  bool isLoading = false;
  bool isResending = false;

  int _resendCooldown = 30;
  Timer? _resendTimer;

  void _startResendTimer() {
    setState(() => _resendCooldown = 30);

    _resendTimer?.cancel(); // Cancel any existing timer
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendOTP({bool isResend = false}) async {
    setState(() => isResend ? isResending = true : isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$serverURL/api/otp/request.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        if (isResend) {
          _startResendTimer();
          _showSuccessDialog('New OTP sent successfully!');
        }
      } else {
        _showErrorDialog(data['error'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      _showErrorDialog('Connection error');
    }

    setState(() => isResend ? isResending = false : isLoading = false);
  }

  Future<void> _verifyOTP() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$serverURL/api/otp/verify.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': _otpController.text}),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const PasswordPage()),
        );
      } else {
        _showErrorDialog(data['error'] ?? 'Invalid OTP');
        _otpController.clear();
        setState(() => isComplete = false);
      }
    } catch (e) {
      _showErrorDialog('Connection error');
    }
    setState(() => isLoading = false);
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

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Success'),
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
  void initState() {
    super.initState();
    _sendOTP();
    _startResendTimer(); // Start timer on initial load
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("OTP Verification"),
      ),
      child: SafeArea(
        child: Center(
          child: isLoading
              ? const CupertinoActivityIndicator(radius: 20)
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 1),
                Text(
                  'Enter the 6-digit code',
                  style: CupertinoTheme.of(context)
                      .textTheme
                      .textStyle
                      .copyWith(
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'sent to $email',
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
                  controller: _otpController,
                  maxLines: 1,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                      letterSpacing: 25.0, fontSize: 50),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: CupertinoColors.label, width: 1.5)),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => isComplete = value.length == 6);
                  },
                ),
                const SizedBox(height: 32),
                CupertinoButton.filled(
                  child: const Text('Verify'),
                  onPressed: isComplete ? _verifyOTP : null,
                ),
                const Spacer(),
                _resendCooldown > 0
                    ? Center(
                      child: Text(
                        'Resend available in $_resendCooldown seconds',
                        style: TextStyle(color: CupertinoColors.secondaryLabel),
                      ),
                    )
                    : CupertinoButton(
                  onPressed: isResending
                      ? null
                      : () => _sendOTP(isResend: true),
                  child: isResending
                      ? const CupertinoActivityIndicator(radius: 10)
                      : const Text(
                    'Resend Code',
                    style: TextStyle(color: CupertinoColors.systemBlue),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }
}