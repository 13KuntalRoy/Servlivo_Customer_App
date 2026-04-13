import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/booking/presentation/bloc/booking_event.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/phone_login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/catalog/presentation/screens/catalog_screen.dart';
import '../../features/catalog/presentation/screens/service_detail_screen.dart';
import '../../features/booking/presentation/screens/bookings_screen.dart';
import '../../features/booking/presentation/screens/booking_create_screen.dart';
import '../../features/booking/presentation/screens/booking_detail_screen.dart';
import '../../features/tracking/presentation/screens/tracking_screen.dart';
import '../../features/chat/presentation/screens/chat_room_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/address/presentation/screens/address_screen.dart';
import '../../features/reviews/presentation/screens/reviews_screen.dart';
import '../../features/subscriptions/presentation/screens/subscriptions_screen.dart';
import '../../features/prime/presentation/screens/prime_screen.dart';
import '../../features/payment/presentation/screens/payment_screen.dart';
import '../di/injection.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';
import '../../features/catalog/presentation/cubit/catalog_cubit.dart';
import '../../features/tracking/presentation/bloc/tracking_bloc.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/address/presentation/cubit/address_cubit.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../../features/reviews/presentation/cubit/review_cubit.dart';
import '../../features/subscriptions/presentation/cubit/subscription_cubit.dart';
import '../../features/prime/presentation/cubit/prime_cubit.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';

// Route name constants
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const phoneLogin = '/phone-login';
  static const register = '/register';
  static const otp = '/otp';
  static const forgotPassword = '/forgot-password';

  static const home = '/home';
  static const catalog = '/catalog';
  static const bookings = '/bookings';
  static const chat = '/chat';
  static const wallet = '/wallet';
  static const profile = '/profile';

  static const serviceDetail = '/service/:id';
  static const bookingCreate = '/booking/new';
  static const bookingDetail = '/booking/:id';
  static const trackingDetail = '/booking/:id/tracking';
  static const chatRoom = '/chat/:roomId';

  static const address = '/address';
  static const reviews = '/reviews/:vendorId';
  static const subscriptions = '/subscriptions';
  static const prime = '/prime';
  static const payment = '/payment';

  static String serviceDetailPath(String id) => '/service/$id';
  static String bookingDetailPath(String id) => '/booking/$id';
  static String trackingDetailPath(String id) => '/booking/$id/tracking';
  static String chatRoomPath(String roomId) => '/chat/$roomId';
  static String reviewsPath(String vendorId) => '/reviews/$vendorId';
}

class AppRouter {
  AppRouter._();

  static GoRouter config(AuthBloc authBloc) {
    // Stays true until the splash screen calls context.go() to leave
    bool splashShowing = true;

    return GoRouter(
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final loc = state.matchedLocation;

        // Always let splash through — it handles its own navigation
        if (loc == AppRoutes.splash) {
          splashShowing = true;
          return null;
        }

        // Splash just navigated away — allow it
        if (splashShowing) {
          splashShowing = false;
          return null;
        }

        final authRoutes = [
          AppRoutes.onboarding,
          AppRoutes.login,
          AppRoutes.phoneLogin,
          AppRoutes.register,
          AppRoutes.otp,
          AppRoutes.forgotPassword,
        ];
        final isOnAuthRoute = authRoutes.any((r) => loc == r || loc.startsWith(r));

        if (!isAuthenticated && !isOnAuthRoute) {
          return AppRoutes.login;
        }
        if (isAuthenticated && isOnAuthRoute) {
          return AppRoutes.home;
        }
        return null;
      },
      refreshListenable: _AuthBlocListenable(authBloc),
      routes: [
        // ── Splash ──────────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, __) => const SplashScreen(),
        ),

        // ── Auth routes ─────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (_, __) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.otp,
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return OtpScreen(
              phone: extra['phone'] as String? ?? '',
              email: extra['email'] as String? ?? '',
            );
          },
        ),
        GoRoute(
          path: AppRoutes.phoneLogin,
          builder: (_, __) => const PhoneLoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, __) => const ForgotPasswordScreen(),
        ),

        // ── Shell route — bottom navigation ──────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => _MainShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (_, __) => BlocProvider(
                create: (_) => sl<HomeBloc>()..add(const HomeDataRequested()),
                child: const HomeScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.catalog,
              builder: (_, state) {
                final categoryId =
                    (state.extra as Map<String, dynamic>?)?['category_id'] as String? ??
                    state.uri.queryParameters['category_id'];
                return BlocProvider(
                  create: (_) => sl<CatalogCubit>()..loadCategories(),
                  child: CatalogScreen(categoryId: categoryId),
                );
              },
            ),
            GoRoute(
              path: AppRoutes.bookings,
              builder: (_, __) => BlocProvider(
                create: (_) => sl<BookingBloc>()
                  ..add(const BookingsLoadRequested()),
                child: const BookingsScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.wallet,
              builder: (_, __) => BlocProvider(
                create: (_) => sl<WalletCubit>()..load(),
                child: const WalletScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (_, __) => BlocProvider(
                create: (_) => sl<ProfileCubit>()..loadProfile(),
                child: const ProfileScreen(),
              ),
            ),
          ],
        ),

        // ── Service detail ───────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.serviceDetail,
          builder: (_, state) => BlocProvider(
            create: (_) => sl<CatalogCubit>()
              ..loadServiceDetail(state.pathParameters['id']!),
            child: ServiceDetailScreen(
              serviceId: state.pathParameters['id']!,
            ),
          ),
        ),

        // ── Booking ──────────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.bookingCreate,
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<BookingBloc>()),
                BlocProvider(create: (_) => sl<AddressCubit>()..loadAddresses()),
              ],
              child: BookingCreateScreen(
                serviceId: extra['service_id'] as String? ?? '',
                servicePrice: (extra['service_price'] as num?)?.toDouble() ?? 0,
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.bookingDetail,
          builder: (_, state) => BlocProvider(
            create: (_) => sl<BookingBloc>()
              ..add(BookingDetailRequested(state.pathParameters['id']!)),
            child: BookingDetailScreen(
              bookingId: state.pathParameters['id']!,
            ),
          ),
        ),

        // ── Tracking ─────────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.trackingDetail,
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return BlocProvider(
              create: (_) => sl<TrackingBloc>()
                ..add(TrackingStarted(state.pathParameters['id']!)),
              child: TrackingScreen(
                bookingId: state.pathParameters['id']!,
                vendorName: extra['vendor_name'] as String?,
                completionCode: extra['completion_code'] as String?,
                bookingStatus: extra['booking_status'] as String?,
              ),
            );
          },
        ),

        // ── Chat ─────────────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.chatRoom,
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return BlocProvider(
              create: (_) => sl<ChatBloc>()
                ..add(ChatRoomOpened(state.pathParameters['roomId']!)),
              child: ChatRoomScreen(
                roomId: state.pathParameters['roomId']!,
                vendorName: extra['vendor_name'] as String?,
              ),
            );
          },
        ),

        // ── Address ──────────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.address,
          builder: (_, __) => BlocProvider(
            create: (_) => sl<AddressCubit>()..loadAddresses(),
            child: const AddressScreen(),
          ),
        ),

        // ── Reviews ──────────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.reviews,
          builder: (_, state) => BlocProvider(
            create: (_) => sl<ReviewCubit>()
              ..loadVendorReviews(state.pathParameters['vendorId']!),
            child: ReviewsScreen(
              vendorId: state.pathParameters['vendorId']!,
            ),
          ),
        ),

        // ── Subscriptions ────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.subscriptions,
          builder: (_, __) => BlocProvider(
            create: (_) => sl<SubscriptionCubit>()..load(),
            child: const SubscriptionsScreen(),
          ),
        ),

        // ── Prime ─────────────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.prime,
          builder: (_, __) => BlocProvider(
            create: (_) => sl<PrimeCubit>()..load(),
            child: const PrimeScreen(),
          ),
        ),

        // ── Payment ──────────────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.payment,
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return BlocProvider(
              create: (_) => sl<PaymentBloc>(),
              child: PaymentScreen(
                bookingId: extra['booking_id'] as String? ?? '',
                amount: (extra['amount'] as num?)?.toDouble() ?? 0,
              ),
            );
          },
        ),
      ],
      errorBuilder: (_, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.error}')),
      ),
    );
  }
}

/// Makes GoRouter listen to AuthBloc state changes for re-evaluation of guards
class _AuthBlocListenable extends ChangeNotifier {
  _AuthBlocListenable(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}

/// Bottom navigation shell
class _MainShell extends StatefulWidget {
  final Widget child;
  const _MainShell({required this.child});

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  static const _tabs = [
    AppRoutes.home,
    AppRoutes.bookings,
    AppRoutes.catalog,
    AppRoutes.wallet,
    AppRoutes.profile,
  ];

  int _indexFromLocation(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  void _onTap(int index) {
    context.go(_tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexFromLocation(location);
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
