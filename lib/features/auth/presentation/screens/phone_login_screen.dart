import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Prepend +91 if user entered just digits
    final raw = _phoneCtrl.text.trim();
    final phone = raw.startsWith('+') ? raw : '+91$raw';
    context.read<AuthBloc>().add(AuthPhoneSendOtpRequested(phone: phone));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPhoneOtpSent) {
          context.push(
            AppRoutes.otp,
            extra: {'phone': state.phone, 'email': ''},
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Enter your phone',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We\'ll send a 6-digit OTP to verify your number',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _sendOtp(),
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🇮🇳', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 4),
                            Text('+91',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(minWidth: 0),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      final digits = v.trim().replaceAll(RegExp(r'\D'), '');
                      if (digits.length != 10) {
                        return 'Enter a valid 10-digit mobile number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AuthLoading ? null : _sendOtp,
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Send OTP'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'OTP is valid for 10 minutes',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textHint),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
