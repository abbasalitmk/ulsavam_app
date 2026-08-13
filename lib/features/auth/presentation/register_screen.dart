import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../districts/providers/districts_provider.dart';
import '../../shell/presentation/main_shell.dart';
import '../providers/auth_provider.dart';
import 'auth_error_utils.dart';

const _kGenderOptions = [
  ('male', 'Male'),
  ('female', 'Female'),
  ('other', 'Other'),
  ('prefer_not_to_say', 'Prefer not to say'),
];

class RegisterScreen extends ConsumerStatefulWidget {
  final String? initialEmail;

  const RegisterScreen({super.key, this.initialEmail});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController();
  late final _emailController =
      TextEditingController(text: widget.initialEmail ?? '');
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender;
  int? _districtId;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    if (email.isEmpty && phone.isEmpty) {
      setState(
          () => _errorMessage = 'Enter your email or phone number.');
      return;
    }
    if (_dateOfBirth == null) {
      setState(() => _errorMessage = 'Please select your date of birth.');
      return;
    }
    if (_gender == null) {
      setState(() => _errorMessage = 'Please select a gender.');
      return;
    }
    if (_districtId == null) {
      setState(() => _errorMessage = 'Please select your district.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authProvider.notifier).register({
        if (email.isNotEmpty) 'email': email,
        if (phone.isNotEmpty) 'phone_number': phone,
        'name': _nameController.text.trim(),
        'password': _passwordController.text,
        'date_of_birth':
            '${_dateOfBirth!.year.toString().padLeft(4, '0')}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}',
        'gender': _gender,
        'district': _districtId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome to Ulsavam!')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = authErrorMessage(e,
            fallback: 'Registration failed. Please check your details.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final districtsAsync = ref.watch(districtsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create Account', style: AppTypography.titleMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Join Ulsavam', style: AppTypography.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Create an account to save events, mark yourself going, and verify festivals.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name *'),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'yourname@kerala.in'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter email or phone (at least one)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password *'),
                validator: (val) => val == null || val.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDateOfBirth,
                child: InputDecorator(
                  decoration: const InputDecoration(
                      labelText: 'Date of Birth *',
                      suffixIcon: Icon(Icons.calendar_today_outlined)),
                  child: Text(
                    _dateOfBirth == null
                        ? 'Select date'
                        : '${_dateOfBirth!.year.toString().padLeft(4, '0')}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}',
                    style: AppTypography.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender *'),
                hint: const Text('Select gender'),
                items: [
                  for (final option in _kGenderOptions)
                    DropdownMenuItem(value: option.$1, child: Text(option.$2)),
                ],
                onChanged: (val) => setState(() => _gender = val),
              ),
              const SizedBox(height: 16),
              districtsAsync.when(
                data: (districts) => DropdownButtonFormField<int>(
                  value: _districtId,
                  decoration: const InputDecoration(labelText: 'District *'),
                  hint: const Text('Select district'),
                  items: [
                    for (final d in districts)
                      DropdownMenuItem(value: d.id, child: Text(d.name)),
                  ],
                  onChanged: (val) => setState(() => _districtId = val),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Could not load districts'),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(_errorMessage!,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.error)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
