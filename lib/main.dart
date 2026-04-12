import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

/// Top-level background FCM handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase — initialize gracefully so app runs even without google-services.json
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (_) {
    // Firebase not configured yet — app still runs, push notifications won't work
  }

  await initDependencies();

  runApp(const ServlivoApp());
}

class ServlivoApp extends StatelessWidget {
  const ServlivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthBloc>()..add(const AuthCheckStatusRequested()),
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          return MaterialApp.router(
            title: 'Servlivo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: AppRouter.config(authBloc),
          );
        },
      ),
    );
  }
}
