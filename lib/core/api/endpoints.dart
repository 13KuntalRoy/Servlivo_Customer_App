class Endpoints {
  Endpoints._();

  static const String baseUrl = 'https://api.servlivo.com/api';
  static const String wsBaseUrl = 'wss://api.servlivo.com/api';

  // ── Auth (proxied to user-service /auth/*) ────────────────────────────────
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify';
  static const String resendOtp = '/auth/resend-otp';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String phoneSendOtp = '/auth/phone/send-otp';
  static const String phoneVerifyOtp = '/auth/phone/verify';

  // ── Profile (proxied to user-service via /api/users/*) ────────────────────
  static const String profile = '/users/profile';
  static const String password = '/users/password';
  static const String avatar = '/users/avatar';
  static const String fcmToken = '/users/fcm-token';
  static const String deleteAccount = '/users/me';
  static const String sessions = '/users/sessions';
  static String sessionById(String id) => '/users/sessions/$id';

  // ── Addresses (user-service /users/address*) ──────────────────────────────
  static const String addAddress = '/users/address';       // POST
  static const String addresses = '/users/addresses';      // GET list
  static String addressById(String id) => '/users/addresses/$id'; // PUT/DELETE

  // ── Favorites (user-service /users/favorites) ─────────────────────────────
  static const String favorites = '/users/favorites';
  static String favoriteByVendorId(String vendorId) => '/users/favorites/$vendorId';

  // ── Prime Membership (user-service /users/prime/*) ────────────────────────
  static const String primePlans = '/users/prime/plans';
  static const String primeMe = '/users/prime/me';
  static const String primeSubscribe = '/users/prime/subscribe';

  // ── Membership via payment-service /api/payments/membership/* ─────────────
  static const String membershipSubscribe = '/payments/membership/subscribe';
  static const String membershipCancel = '/payments/membership/cancel';
  static const String membershipUpgrade = '/payments/membership/upgrade';

  // ── Catalog (proxied to catalog-service via /api/catalog/*) ──────────────
  static const String categories = '/catalog/categories';
  static String subcategoriesByCat(String categoryId) =>
      '/catalog/categories/$categoryId/subcategories';
  static String servicesBySubcat(String subcategoryId) =>
      '/catalog/subcategories/$subcategoryId/services';
  static String serviceById(String serviceId) => '/catalog/services/$serviceId';
  static String serviceAttributes(String serviceId) =>
      '/catalog/services/$serviceId/attributes';
  static const String catalogServices = '/catalog/services';
  static const String catalogAll = '/catalog/all';
  static const String catalogSearch = '/catalog/search';
  static const String catalogAvailability = '/catalog/availability';
  static const String catalogHeatmap = '/catalog/heatmap';
  static const String catalogPackages = '/catalog/packages';

  // ── Bookings (proxied to booking-service via /api/bookings/*) ─────────────
  static const String bookings = '/bookings/';             // trailing slash avoids 301
  static String bookingById(String id) => '/bookings/$id';
  static String bookingHistory(String id) => '/bookings/$id/history';
  static String cancelBooking(String id) => '/bookings/$id/cancel';
  static String rescheduleBooking(String id) => '/bookings/$id/reschedule';
  static String disputeBooking(String id) => '/bookings/$id/dispute';
  static String tipBooking(String id) => '/bookings/$id/tip';
  static String bookingWarranty(String id) => '/bookings/$id/warranty';
  static String claimWarranty(String id) => '/bookings/$id/warranty/claim';
  static const String bookingStats = '/bookings/stats';
  static const String coupons = '/bookings/coupons';
  static const String groupBuys = '/bookings/group-buys';

  // ── Subscriptions (booking-service /subscriptions/*) ─────────────────────
  static const String subscriptions = '/subscriptions/';
  static String subscriptionById(String id) => '/subscriptions/$id';
  static String pauseSubscription(String id) => '/subscriptions/$id/pause';
  static String resumeSubscription(String id) => '/subscriptions/$id/resume';
  static String cancelSubscription(String id) => '/subscriptions/$id/cancel';

  // ── Payments (payment-service via /api/payments/*) ────────────────────────
  static const String initiatePayment = '/payments/initiate';
  static const String verifyPayment = '/payments/verify';
  static const String transactions = '/payments/transactions/';
  static const String refund = '/payments/refund';
  static const String paymentInitiate = initiatePayment;
  static String upiPayment(String bookingId) => '/payments/upi/$bookingId';
  static const String cards = '/payments/cards';
  static String cardById(String id) => '/payments/cards/$id';

  // ── Wallet (payment-service /wallet routes) ───────────────────────────────
  static const String wallet = '/payments/wallet';
  static const String walletTransactions = '/payments/wallet/transactions';

  // ── Reviews (review-service via /api/reviews/*) ───────────────────────────
  static const String reviews = '/reviews';
  static const String myReviews = '/reviews/me/';
  static String vendorReviews(String vendorId) => '/reviews/vendor/$vendorId';
  static String vendorReviewMetrics(String vendorId) =>
      '/reviews/vendor/$vendorId/metrics';

  // ── Chat (chat-service via /api/chat/*) ───────────────────────────────────
  static const String chatRooms = '/chat/rooms';
  static String chatMessages(String roomId) => '/chat/rooms/$roomId/messages';
  static String chatCall(String roomId) => '/chat/rooms/$roomId/call';
  static String chatWs(String roomId) => '$wsBaseUrl/chat/ws/$roomId';

  // ── Tracking (tracking-service via /api/tracking/*) ──────────────────────
  static String trackingWs(String bookingId) =>
      '$wsBaseUrl/tracking/ws/$bookingId';
  static const String nearbyVendors = '/tracking/nearby';
  static String vendorLocation(String vendorId) =>
      '/tracking/vendor/$vendorId';
}
