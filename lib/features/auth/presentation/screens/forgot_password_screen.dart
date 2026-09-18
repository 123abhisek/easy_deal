import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isCodeSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final emailErr = Validators.email(_emailController.text);
    if (emailErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailErr), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    final repo = ref.read(authRepositoryProvider);
    final response = await repo.forgotPassword(_emailController.text);
    setState(() => _isLoading = false);

    if (mounted) {
      if (response.isSuccess) {
        setState(() => _isCodeSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset verification code sent to your email.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to send reset code'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the reset code'), backgroundColor: AppColors.error),
      );
      return;
    }

    final passErr = Validators.password(_newPasswordController.text);
    if (passErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passErr), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    final repo = ref.read(authRepositoryProvider);
    final response = await repo.resetPassword(
      email: _emailController.text,
      code: _codeController.text,
      newPassword: _newPasswordController.text,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successful! Please log in with your new password.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to reset password'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isCodeSent ? 'Enter Reset Code' : 'Forgot Password?',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isCodeSent
                    ? 'Check your inbox for the verification code and set your new password.'
                    : 'Enter your registered email address and we will send you a reset code.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),

              CustomTextField(
                controller: _emailController,
                label: 'Registered Email',
                hint: 'name@example.com',
                readOnly: _isCodeSent,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                validator: Validators.email,
              ),

              if (_isCodeSent) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _codeController,
                  label: 'Reset Code',
                  hint: 'Enter 6-digit code',
                  prefixIcon: const Icon(Icons.pin_outlined, size: 20),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  hint: '••••••••',
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  validator: Validators.password,
                ),
              ],

              const SizedBox(height: 28),
              PrimaryButton(
                text: _isCodeSent ? 'Update Password' : 'Send Reset Code',
                isLoading: _isLoading,
                onPressed: _isCodeSent ? _resetPassword : _sendCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
