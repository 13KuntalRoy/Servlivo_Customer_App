import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

// ignore_for_file: unused_element

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// OTP has been sent — navigate to OTP screen
class AuthOtpSent extends AuthState {
  final String email;

  const AuthOtpSent({required this.email});

  @override
  List<Object> get props => [email];
}

/// Phone OTP sent — navigate to OTP screen with phone number
class AuthPhoneOtpSent extends AuthState {
  final String phone;

  const AuthPhoneOtpSent({required this.phone});

  @override
  List<Object> get props => [phone];
}

/// OTP resent successfully
class AuthOtpResent extends AuthState {
  const AuthOtpResent();
}

/// Registration step 1 complete — OTP sent to email
class AuthRegistered extends AuthState {
  final String email;

  const AuthRegistered({required this.email});

  @override
  List<Object> get props => [email];
}

/// Forgot password email sent
class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

/// Password reset successful
class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

/// Internal state: token exists in storage but full user not loaded yet.
/// Router treats this as authenticated.
class TokenPresent extends AuthAuthenticated {
  TokenPresent() : super(_PlaceholderUser());
}

class _PlaceholderUser extends UserEntity {
  _PlaceholderUser()
      : super(
          id: '',
          email: '',
          phone: '',
          name: '',
          avatarUrl: '',
          role: 'customer',
          isVerified: true,
          isActive: true,
          referralCode: '',
          referredByCode: '',
          primeTier: 'free',
          createdAt: DateTime(2020),
          updatedAt: DateTime(2020),
        );
}
