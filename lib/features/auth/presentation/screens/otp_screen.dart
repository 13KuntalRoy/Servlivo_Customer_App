import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String email;

  const OtpScreen({super.key, required this.phone, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<String> _digits = List.filled(6, '');
  int _resendSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  String get _otp => _digits.join();
  bool get _isComplete => _digits.every((d) => d.isNotEmpty);
  bool get _isPhoneFlow => widget.phone.isNotEmpty;

  void _onDigitTap(String d) {
    final idx = _digits.indexWhere((x) => x.isEmpty);
    if (idx == -1) return;
    setState(() => _digits[idx] = d);
    if (_isComplete) _verify();
  }

  void _onBackspace() {
    final idx = _digits.lastIndexWhere((x) => x.isNotEmpty);
    if (idx == -1) return;
    setState(() => _digits[idx] = '');
  }

  void _verify() {
    if (_isPhoneFlow) {
      context.read<AuthBloc>().add(
            AuthPhoneVerifyRequested(phone: widget.phone, otp: _otp),
          );
    } else {
      context.read<AuthBloc>().add(
            AuthOtpVerifyRequested(email: widget.email, otp: _otp),
          );
    }
  }

  void _resend() {
    if (_isPhoneFlow) {
      context.read<AuthBloc>().add(
            AuthPhoneSendOtpRequested(phone: widget.phone),
          );
    } else {
      context.read<AuthBloc>().add(
            AuthOtpResendRequested(email: widget.email),
          );
    }
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthOtpResent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP resent successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AuthError) {
          // Reset digits on error
          setState(() {
            for (int i = 0; i < 6; i++) { _digits[i] = ''; }
          });
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
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      alignment: Alignment.centerLeft,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isPhoneFlow ? 'VERIFY PHONE 🔐' : 'VERIFY EMAIL 🔐',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ENTER THE 6-DIGIT CODE SENT TO',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email.isNotEmpty ? widget.email : widget.phone,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        _isPhoneFlow ? 'Change number' : 'Change email',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // OTP boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (i) {
                        final filled = _digits[i].isNotEmpty;
                        final isActive =
                            i == _digits.indexWhere((d) => d.isEmpty);
                        return Container(
                          width: 44,
                          height: 52,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isActive
                                  ? AppColors.secondary
                                  : filled
                                      ? AppColors.secondary
                                      : AppColors.border,
                              width: isActive ? 2 : 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: filled
                                ? AppColors.secondary.withValues(alpha:0.05)
                                : AppColors.surface,
                          ),
                          child: Center(
                            child: Text(
                              filled ? _digits[i] : '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Resend
                    _resendSeconds > 0
                        ? RichText(
                            text: TextSpan(
                              text: "DIDN'T RECEIVE THE CODE? ",
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Resend in '
                                      '${_resendSeconds.toString().padLeft(2, '0')}s',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : TextButton(
                            onPressed: _resend,
                            child: const Text("Resend OTP"),
                          ),
                  ],
                ),
              ),

              const Spacer(),

              // Custom numpad
              _NumPad(onDigit: _onDigitTap, onBackspace: _onBackspace),

              // Verify button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed:
                          (_isComplete && state is! AuthLoading) ? _verify : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('VERIFY & CONTINUE →'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;

  const _NumPad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: keys.map((row) {
          return Row(
            children: row.map((key) {
              if (key.isEmpty) return const Expanded(child: SizedBox());
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (key == '⌫') {
                      onBackspace();
                    } else {
                      onDigit(key);
                    }
                  },
                  child: Container(
                    height: 64,
                    alignment: Alignment.center,
                    child: Text(
                      key,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
