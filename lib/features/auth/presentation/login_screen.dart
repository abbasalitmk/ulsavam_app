import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../shell/presentation/main_shell.dart';
import '../providers/auth_provider.dart';
import 'auth_error_utils.dart';
import 'otp_screen.dart';
import 'register_screen.dart';

enum _LoginMode { emailOtp, password }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  _LoginMode _mode = _LoginMode.emailOtp;

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToRegister({String? prefillEmail}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterScreen(initialEmail: prefillEmail),
      ),
    );
  }

  Future<void> _handleRequestOtp() async {
    setState(() => _errorMessage = null);
    final identifier = _emailController.text.trim();

    if (identifier.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address.');
      return;
    }

    try {
      final message = await ref.read(authProvider.notifier).requestOtp(
            identifier: identifier,
            method: 'email',
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(message),
              backgroundColor: AppColors.tertiaryContainer),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OTPScreen(identifier: identifier, method: 'email'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      if (isAccountNotFound(e)) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('No account found'),
            content: Text(
                "We couldn't find an account for $identifier. Would you like to create one?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _goToRegister(prefillEmail: identifier);
                },
                child: const Text('Register'),
              ),
            ],
          ),
        );
        return;
      }

      setState(() => _errorMessage = authErrorMessage(e,
          fallback:
              'Failed to send OTP. Please check your email address.'));
    }
  }

  Future<void> _handlePasswordLogin() async {
    setState(() => _errorMessage = null);
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() =>
          _errorMessage = 'Enter your email/phone and password.');
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .login(username: username, password: password);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _errorMessage =
          authErrorMessage(e, fallback: 'Invalid username or password.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Sign In', style: AppTypography.titleMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back', style: AppTypography.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Sign in to save events, mark yourself going, and verify festivals.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 24),
            _ModeToggle(
              mode: _mode,
              onChanged: (mode) => setState(() {
                _mode = mode;
                _errorMessage = null;
              }),
            ),
            const SizedBox(height: 24),
            if (_mode == _LoginMode.emailOtp) ...[
              TextField(
                controller: _emailController,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'yourname@kerala.in',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ] else ...[
              TextField(
                controller: _usernameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Email or Phone Number',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: authState.isLoading
                  ? null
                  : (_mode == _LoginMode.emailOtp
                      ? _handleRequestOtp
                      : _handlePasswordLogin),
              child: authState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(_mode == _LoginMode.emailOtp
                      ? 'Request OTP Code'
                      : 'Login'),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => _goToRegister(),
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.bodySmall,
                    children: [
                      const TextSpan(text: "New to Ulsavam? "),
                      TextSpan(
                        text: 'Register',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final _LoginMode mode;
  final ValueChanged<_LoginMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: 'Email OTP',
              selected: mode == _LoginMode.emailOtp,
              onTap: () => onChanged(_LoginMode.emailOtp),
            ),
          ),
          Expanded(
            child: _ModeButton(
              label: 'Username & Password',
              selected: mode == _LoginMode.password,
              onTap: () => onChanged(_LoginMode.password),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceContainerLowest : null,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06), blurRadius: 4),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.labelMedium.copyWith(
            fontSize: 12,
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
