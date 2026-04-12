import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/send_phone_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/verify_phone_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final VerifyOtpUseCase _verifyOtp;
  final ResendOtpUseCase _resendOtp;
  final LogoutUseCase _logout;
  final ForgotPasswordUseCase _forgotPassword;
  final ResetPasswordUseCase _resetPassword;
  final SendPhoneOtpUseCase _sendPhoneOtp;
  final VerifyPhoneOtpUseCase _verifyPhoneOtp;
  final SecureStorageService _storage;

  AuthBloc({
    required LoginUseCase login,
    required RegisterUseCase register,
    required VerifyOtpUseCase verifyOtp,
    required ResendOtpUseCase resendOtp,
    required LogoutUseCase logout,
    required ForgotPasswordUseCase forgotPassword,
    required ResetPasswordUseCase resetPassword,
    required SendPhoneOtpUseCase sendPhoneOtp,
    required VerifyPhoneOtpUseCase verifyPhoneOtp,
    required SecureStorageService storage,
  })  : _login = login,
        _register = register,
        _verifyOtp = verifyOtp,
        _resendOtp = resendOtp,
        _logout = logout,
        _forgotPassword = forgotPassword,
        _resetPassword = resetPassword,
        _sendPhoneOtp = sendPhoneOtp,
        _verifyPhoneOtp = verifyPhoneOtp,
        _storage = storage,
        super(const AuthInitial()) {
    on<AuthCheckStatusRequested>(_onCheckStatus);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthOtpVerifyRequested>(_onOtpVerifyRequested);
    on<AuthOtpResendRequested>(_onOtpResendRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthPhoneSendOtpRequested>(_onPhoneSendOtpRequested);
    on<AuthPhoneVerifyRequested>(_onPhoneVerifyRequested);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    final hasToken = await _storage.hasAccessToken;
    if (hasToken) {
      // Emit a lightweight "authenticated" state with placeholder user.
      // Real user data is loaded by HomeBloc/ProfileCubit.
      emit(TokenPresent());
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _login(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _register(
      RegisterParams(
        email: event.email,
        password: event.password,
        phone: event.phone,
        name: event.name,
        referralCode: event.referralCode,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthRegistered(email: event.email)),
    );
  }

  Future<void> _onOtpVerifyRequested(
    AuthOtpVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _verifyOtp(
      VerifyOtpParams(email: event.email, otp: event.otp),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onOtpResendRequested(
    AuthOtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _resendOtp(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthOtpResent()),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _forgotPassword(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthPasswordResetSent()),
    );
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _resetPassword(
      ResetPasswordParams(
        email: event.email,
        otp: event.otp,
        newPassword: event.newPassword,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthPasswordResetSuccess()),
    );
  }

  Future<void> _onPhoneSendOtpRequested(
    AuthPhoneSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _sendPhoneOtp(event.phone);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthPhoneOtpSent(phone: event.phone)),
    );
  }

  Future<void> _onPhoneVerifyRequested(
    AuthPhoneVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _verifyPhoneOtp(
      VerifyPhoneOtpParams(phone: event.phone, otp: event.otp),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}

