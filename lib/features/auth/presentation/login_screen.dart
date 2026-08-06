import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import 'otp_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOtp() async {
    setState(() => _errorMessage = null);
    final isPhoneTab = _tabController.index == 0;
    final identifier = isPhoneTab ? _phoneController.text.trim() : _emailController.text.trim();
    final method = isPhoneTab ? 'phone' : 'email';

    if (identifier.isEmpty) {
      setState(() => _errorMessage = 'Please enter your ${isPhoneTab ? "phone number" : "email address"}.');
      return;
    }

    try {
      final message = await ref.read(authProvider.notifier).requestOtp(
            identifier: identifier,
            method: method,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.tertiaryContainer),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OTPScreen(identifier: identifier, method: method),
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to send OTP. Please check identifier.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Sign In / Register', style: AppTypography.titleMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars, color: AppColors.secondaryContainer, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      'Ulsavam Malayalam Auth',
                      style: AppTypography.titleMedium.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Passwordless Login via OTP',
              style: AppTypography.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your phone number or email to receive a 6-digit verification code.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 24),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Phone OTP'),
                Tab(text: 'Email OTP'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 100,
              child: TabBarView(
                controller: _tabController,
                children: [
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '+91 9876543210',
                      prefixIcon: Icon(Icons.phone_android),
                    ),
                  ),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'yourname@kerala.in',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: authState.isLoading ? null : _handleRequestOtp,
              child: authState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Request OTP Code'),
            ),
          ],
        ),
      ),
    );
  }
}
