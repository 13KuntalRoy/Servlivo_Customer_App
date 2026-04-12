import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../api/api_client.dart';
import '../network/network_info.dart';
import '../storage/secure_storage.dart';
import '../websocket/ws_client.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../../features/auth/domain/usecases/send_phone_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_phone_otp_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Profile
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/upload_avatar_usecase.dart';
import '../../features/profile/domain/usecases/change_password_usecase.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

// Address
import '../../features/address/data/datasources/address_remote_data_source.dart';
import '../../features/address/data/repositories/address_repository_impl.dart';
import '../../features/address/domain/repositories/address_repository.dart';
import '../../features/address/domain/usecases/get_addresses_usecase.dart';
import '../../features/address/domain/usecases/create_address_usecase.dart';
import '../../features/address/domain/usecases/update_address_usecase.dart';
import '../../features/address/domain/usecases/delete_address_usecase.dart';
import '../../features/address/presentation/cubit/address_cubit.dart';

// Catalog
import '../../features/catalog/data/datasources/catalog_remote_data_source.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/domain/usecases/get_categories_usecase.dart';
import '../../features/catalog/domain/usecases/get_subcategories_usecase.dart';
import '../../features/catalog/domain/usecases/get_services_usecase.dart';
import '../../features/catalog/domain/usecases/get_service_detail_usecase.dart';
import '../../features/catalog/domain/usecases/search_services_usecase.dart';
import '../../features/catalog/domain/usecases/get_availability_usecase.dart';
import '../../features/catalog/presentation/cubit/catalog_cubit.dart';

// Booking
import '../../features/booking/data/datasources/booking_remote_data_source.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/booking/domain/usecases/create_booking_usecase.dart';
import '../../features/booking/domain/usecases/get_bookings_usecase.dart';
import '../../features/booking/domain/usecases/get_booking_detail_usecase.dart';
import '../../features/booking/domain/usecases/cancel_booking_usecase.dart';
import '../../features/booking/domain/usecases/reschedule_booking_usecase.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';

// Tracking
import '../../features/tracking/data/datasources/tracking_remote_data_source.dart';
import '../../features/tracking/data/repositories/tracking_repository_impl.dart';
import '../../features/tracking/domain/repositories/tracking_repository.dart';
import '../../features/tracking/presentation/bloc/tracking_bloc.dart';

// Chat
import '../../features/chat/data/datasources/chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/chat_usecases.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

// Payment
import '../../features/payment/data/datasources/payment_remote_data_source.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/usecases/initiate_payment_usecase.dart';
import '../../features/payment/domain/usecases/verify_payment_usecase.dart';
import '../../features/payment/domain/usecases/get_transactions_usecase.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';

// Wallet
import '../../features/wallet/data/datasources/wallet_remote_data_source.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/get_wallet_usecase.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';

// Reviews
import '../../features/reviews/data/datasources/review_remote_data_source.dart';
import '../../features/reviews/data/repositories/review_repository_impl.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';
import '../../features/reviews/domain/usecases/review_usecases.dart';
import '../../features/reviews/presentation/cubit/review_cubit.dart';

// Subscriptions
import '../../features/subscriptions/data/datasources/subscription_remote_data_source.dart';
import '../../features/subscriptions/data/repositories/subscription_repository_impl.dart';
import '../../features/subscriptions/domain/repositories/subscription_repository.dart';
import '../../features/subscriptions/domain/usecases/subscription_usecases.dart';
import '../../features/subscriptions/presentation/cubit/subscription_cubit.dart';

// Prime
import '../../features/prime/data/datasources/prime_remote_data_source.dart';
import '../../features/prime/data/repositories/prime_repository_impl.dart';
import '../../features/prime/domain/repositories/prime_repository.dart';
import '../../features/prime/domain/usecases/prime_usecases.dart';
import '../../features/prime/presentation/cubit/prime_cubit.dart';

// Home
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_data_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── External ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // ── Core ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageServiceImpl(),
  );
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );
  sl.registerLazySingleton<WsClient>(() => WsClient(sl<SecureStorageService>()));
  sl.registerLazySingleton<Dio>(() => ApiClient.create(sl<SecureStorageService>()));

  // ── Features ──────────────────────────────────────────────────────────────
  _registerAuth();
  _registerProfile();
  _registerAddress();
  _registerCatalog();
  _registerBooking();
  _registerTracking();
  _registerChat();
  _registerPayment();
  _registerWallet();
  _registerReviews();
  _registerSubscriptions();
  _registerPrime();
  _registerHome();
}

void _registerAuth() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: sl<AuthRemoteDataSource>(),
      storage: sl<SecureStorageService>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResendOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SendPhoneOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyPhoneOtpUseCase(sl<AuthRepository>()));
  // AuthBloc is singleton — router guard reads it at startup
  sl.registerSingleton<AuthBloc>(
    AuthBloc(
      login: sl<LoginUseCase>(),
      register: sl<RegisterUseCase>(),
      verifyOtp: sl<VerifyOtpUseCase>(),
      resendOtp: sl<ResendOtpUseCase>(),
      logout: sl<LogoutUseCase>(),
      forgotPassword: sl<ForgotPasswordUseCase>(),
      resetPassword: sl<ResetPasswordUseCase>(),
      sendPhoneOtp: sl<SendPhoneOtpUseCase>(),
      verifyPhoneOtp: sl<VerifyPhoneOtpUseCase>(),
      storage: sl<SecureStorageService>(),
    ),
  );
}

void _registerProfile() {
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remote: sl<ProfileRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl<ProfileRepository>()));
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getProfile: sl<GetProfileUseCase>(),
      updateProfile: sl<UpdateProfileUseCase>(),
      uploadAvatar: sl<UploadAvatarUseCase>(),
      changePassword: sl<ChangePasswordUseCase>(),
    ),
  );
}

void _registerAddress() {
  sl.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(
      remote: sl<AddressRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetAddressesUseCase(sl<AddressRepository>()));
  sl.registerLazySingleton(() => CreateAddressUseCase(sl<AddressRepository>()));
  sl.registerLazySingleton(() => UpdateAddressUseCase(sl<AddressRepository>()));
  sl.registerLazySingleton(() => DeleteAddressUseCase(sl<AddressRepository>()));
  sl.registerFactory<AddressCubit>(
    () => AddressCubit(
      getAddresses: sl<GetAddressesUseCase>(),
      createAddress: sl<CreateAddressUseCase>(),
      updateAddress: sl<UpdateAddressUseCase>(),
      deleteAddress: sl<DeleteAddressUseCase>(),
    ),
  );
}

void _registerCatalog() {
  sl.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(
      remote: sl<CatalogRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl<CatalogRepository>()));
  sl.registerLazySingleton(() => GetSubcategoriesUseCase(sl<CatalogRepository>()));
  sl.registerLazySingleton(() => GetServicesUseCase(sl<CatalogRepository>()));
  sl.registerLazySingleton(() => GetServiceDetailUseCase(sl<CatalogRepository>()));
  sl.registerLazySingleton(() => SearchServicesUseCase(sl<CatalogRepository>()));
  sl.registerLazySingleton(() => GetAvailabilityUseCase(sl<CatalogRepository>()));
  sl.registerFactory<CatalogCubit>(
    () => CatalogCubit(
      getCategories: sl<GetCategoriesUseCase>(),
      getSubcategories: sl<GetSubcategoriesUseCase>(),
      getServices: sl<GetServicesUseCase>(),
      getServiceDetail: sl<GetServiceDetailUseCase>(),
      searchServices: sl<SearchServicesUseCase>(),
      getAvailability: sl<GetAvailabilityUseCase>(),
    ),
  );
}

void _registerBooking() {
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(
      remote: sl<BookingRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => CreateBookingUseCase(sl<BookingRepository>()));
  sl.registerLazySingleton(() => GetBookingsUseCase(sl<BookingRepository>()));
  sl.registerLazySingleton(() => GetBookingDetailUseCase(sl<BookingRepository>()));
  sl.registerLazySingleton(() => CancelBookingUseCase(sl<BookingRepository>()));
  sl.registerLazySingleton(() => RescheduleBookingUseCase(sl<BookingRepository>()));
  sl.registerFactory<BookingBloc>(
    () => BookingBloc(
      createBooking: sl<CreateBookingUseCase>(),
      getBookings: sl<GetBookingsUseCase>(),
      getBookingDetail: sl<GetBookingDetailUseCase>(),
      cancelBooking: sl<CancelBookingUseCase>(),
      rescheduleBooking: sl<RescheduleBookingUseCase>(),
    ),
  );
}

void _registerTracking() {
  sl.registerLazySingleton<TrackingRemoteDataSource>(
    () => TrackingRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(
      remote: sl<TrackingRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerFactory<TrackingBloc>(
    () => TrackingBloc(wsClient: sl<WsClient>()),
  );
}

void _registerChat() {
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remote: sl<ChatRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetChatHistoryUseCase(sl<ChatRepository>()));
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(
      wsClient: sl<WsClient>(),
      getHistory: sl<GetChatHistoryUseCase>(),
    ),
  );
}

void _registerPayment() {
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(
      remote: sl<PaymentRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => InitiatePaymentUseCase(sl<PaymentRepository>()));
  sl.registerLazySingleton(() => VerifyPaymentUseCase(sl<PaymentRepository>()));
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl<PaymentRepository>()));
  sl.registerFactory<PaymentBloc>(
    () => PaymentBloc(
      initiatePayment: sl<InitiatePaymentUseCase>(),
      verifyPayment: sl<VerifyPaymentUseCase>(),
      getTransactions: sl<GetTransactionsUseCase>(),
    ),
  );
}

void _registerWallet() {
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(
      remote: sl<WalletRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetWalletBalanceUseCase(sl<WalletRepository>()));
  sl.registerLazySingleton(() => GetWalletTransactionsUseCase(sl<WalletRepository>()));
  sl.registerFactory<WalletCubit>(
    () => WalletCubit(
      getBalance: sl<GetWalletBalanceUseCase>(),
      getTransactions: sl<GetWalletTransactionsUseCase>(),
    ),
  );
}

void _registerReviews() {
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(
      remote: sl<ReviewRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => PostReviewUseCase(sl<ReviewRepository>()));
  sl.registerLazySingleton(() => GetVendorReviewsUseCase(sl<ReviewRepository>()));
  sl.registerFactory<ReviewCubit>(
    () => ReviewCubit(
      postReview: sl<PostReviewUseCase>(),
      getReviews: sl<GetVendorReviewsUseCase>(),
    ),
  );
}

void _registerSubscriptions() {
  sl.registerLazySingleton<SubscriptionRemoteDataSource>(
    () => SubscriptionRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      remote: sl<SubscriptionRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetSubscriptionsUseCase(sl<SubscriptionRepository>()));
  sl.registerLazySingleton(() => PauseSubscriptionUseCase(sl<SubscriptionRepository>()));
  sl.registerLazySingleton(() => ResumeSubscriptionUseCase(sl<SubscriptionRepository>()));
  sl.registerLazySingleton(() => CancelSubscriptionUseCase(sl<SubscriptionRepository>()));
  sl.registerFactory<SubscriptionCubit>(
    () => SubscriptionCubit(
      getSubscriptions: sl<GetSubscriptionsUseCase>(),
      pause: sl<PauseSubscriptionUseCase>(),
      resume: sl<ResumeSubscriptionUseCase>(),
      cancel: sl<CancelSubscriptionUseCase>(),
    ),
  );
}

void _registerPrime() {
  sl.registerLazySingleton<PrimeRemoteDataSource>(
    () => PrimeRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<PrimeRepository>(
    () => PrimeRepositoryImpl(
      remote: sl<PrimeRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetPrimePlansUseCase(sl<PrimeRepository>()));
  sl.registerLazySingleton(() => SubscribePrimeUseCase(sl<PrimeRepository>()));
  sl.registerLazySingleton(() => GetPrimeMembershipUseCase(sl<PrimeRepository>()));
  sl.registerFactory<PrimeCubit>(
    () => PrimeCubit(
      getPlans: sl<GetPrimePlansUseCase>(),
      subscribe: sl<SubscribePrimeUseCase>(),
      getMembership: sl<GetPrimeMembershipUseCase>(),
    ),
  );
}

void _registerHome() {
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remote: sl<HomeRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl<HomeRepository>()));
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(getHomeData: sl<GetHomeDataUseCase>()),
  );
}
