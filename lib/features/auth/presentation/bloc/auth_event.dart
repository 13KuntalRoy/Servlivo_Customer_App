import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckStatusRequested extends AuthEvent {
  const AuthCheckStatusRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String phone;
  final String name;
  final String? referralCode;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.phone,
    required this.name,
    this.referralCode,
  });

  @override
  List<Object?> get props => [email, password, phone, name, referralCode];
}

class AuthOtpVerifyRequested extends AuthEvent {
  final String email;
  final String otp;

  const AuthOtpVerifyRequested({required this.email, required this.otp});

  @override
  List<Object> get props => [email, otp];
}

class AuthOtpResendRequested extends AuthEvent {
  final String email;

  const AuthOtpResendRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;
  final String otp;
  final String newPassword;

  const AuthResetPasswordRequested({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  @override
  List<Object> get props => [email, otp, newPassword];
}

class AuthPhoneSendOtpRequested extends AuthEvent {
  final String phone;

  const AuthPhoneSendOtpRequested({required this.phone});

  @override
  List<Object> get props => [phone];
}

class AuthPhoneVerifyRequested extends AuthEvent {
  final String phone;
  final String otp;

  const AuthPhoneVerifyRequested({required this.phone, required this.otp});

  @override
  List<Object> get props => [phone, otp];
}
