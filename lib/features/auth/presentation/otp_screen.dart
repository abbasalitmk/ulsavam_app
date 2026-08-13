import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../../shell/presentation/main_shell.dart';
import 'auth_error_utils.dart';
import 'register_screen.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String identifier;
  final String method;

  const OTPScreen({super.key, required this.identifier, required this.method});

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final _otpController = TextEditingController();
  String? _errorMessage;

  Future<void> _verifyOtp() async {
    setState(() => _errorMessage = null);
    final code = _otpController.text.trim();

    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter a 6-digit OTP code.');
      return;
    }

    try {
      await ref.read(authProvider.notifier).verifyOtp(
            identifier: widget.identifier,
            code: code,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Login Successful! Welcome to Ulsavam.')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    } catch (e) {
      if (isAccountNotFound(e) && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RegisterScreen(initialEmail: widget.identifier),
          ),
        );
        return;
      }
      setState(() => _errorMessage =
          authErrorMessage(e, fallback: 'Invalid or expired OTP code.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Verification Code', style: AppTypography.titleMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter 6-Digit OTP',
              style: AppTypography.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Code sent to ${widget.identifier}',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: AppTypography.displayLarge
                  .copyWith(fontSize: 32, letterSpacing: 8),
              decoration: const InputDecoration(
                hintText: '123456',
                counterText: '',
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: authState.isLoading ? null : _verifyOtp,
              child: authState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Verify & Login'),
            ),
          ],
        ),
      ),
    );
  }
}
