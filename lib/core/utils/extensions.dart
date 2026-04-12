import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ── Either extensions ─────────────────────────────────────────────────────────
extension EitherX<L, R> on Either<L, R> {
  R get rightValue => (this as Right<L, R>).value;
  L get leftValue => (this as Left<L, R>).value;
  bool get isRight => fold((_) => false, (_) => true);
  bool get isLeft => !isRight;
}

// ── String extensions ─────────────────────────────────────────────────────────
extension StringX on String {
  bool get isValidPhone {
    final digits = replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 && digits.length <= 13;
  }

  bool get isValidEmail =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(trim());

  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : w.capitalize)
      .join(' ');

  String get initials {
    final parts = trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Format raw phone number with country code display
  String get maskedPhone {
    if (length < 4) return this;
    return '${substring(0, length - 4).replaceAll(RegExp(r'\d'), '•')}${substring(length - 4)}';
  }
}

// ── DateTime extensions ───────────────────────────────────────────────────────
extension DateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  String get displayDate {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    return DateFormat('dd MMM yyyy').format(this);
  }

  String get displayDateTime =>
      DateFormat('dd MMM yyyy, hh:mm a').format(this);

  String get displayTime => DateFormat('hh:mm a').format(this);

  String get apiFormat => toUtc().toIso8601String();
}

// ── int extensions ────────────────────────────────────────────────────────────
extension IntX on int {
  /// Convert seconds to "12 min" or "1 h 5 min"
  String get etaDisplay {
    final minutes = (this / 60).round();
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h h' : '$h h $m min';
  }
}

// ── double extensions ─────────────────────────────────────────────────────────
extension DoubleX on double {
  String get inr => '₹${toStringAsFixed(0)}';
  String get inrDecimal => '₹${toStringAsFixed(2)}';
}

// ── BuildContext extensions ───────────────────────────────────────────────────
extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isSmallScreen => screenWidth < 360;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void hideKeyboard() => FocusScope.of(this).unfocus();
}
