import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../catalog/domain/entities/category_entity.dart';
import '../../domain/entities/home_data_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remote;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, HomeDataEntity>> getHomeData() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final data = await remote.getHomeData();

      final categoriesRaw = data['categories'];
      final List<dynamic> categoriesList = categoriesRaw is List
          ? categoriesRaw
          : (categoriesRaw as Map?)?['data'] as List? ?? [];

      final categories = categoriesList.map((c) {
        final m = c as Map<String, dynamic>;
        return CategoryEntity(
          id: m['id'] as String,
          name: m['name'] as String,
          slug: m['slug'] as String? ?? '',
          description: m['description'] as String? ?? '',
          iconUrl: m['icon_url'] as String? ?? '',
          isActive: m['is_active'] as bool? ?? true,
          sortOrder: m['sort_order'] as int? ?? 0,
          serviceCount: m['service_count'] as int? ?? 0,
        );
      }).toList();

      final popularRaw = data['popular_services'];
      final List<dynamic> popularList = popularRaw is List
          ? popularRaw
          : (popularRaw as Map?)?['data'] as List? ?? [];

      final popularServices = popularList.map((s) {
        final m = s as Map<String, dynamic>;
        return PopularServiceEntity(
          id: m['id'] as String,
          name: m['name'] as String,
          imageUrl: m['image_url'] as String? ?? '',
          price: (m['base_price'] as num?)?.toDouble() ?? 0,
          rating: (m['rating'] as num?)?.toDouble() ?? 0,
          duration: m['duration'] as String? ?? '',
          categoryName: m['category_name'] as String? ?? '',
        );
      }).toList();

      // Parse ongoing booking
      final ongoingRaw = data['ongoing_bookings'];
      final List<dynamic> ongoingList = ongoingRaw is List
          ? ongoingRaw
          : (ongoingRaw as Map?)?['data'] as List? ?? [];
      OngoingBookingSummary? ongoingBooking;
      if (ongoingList.isNotEmpty) {
        final b = ongoingList.first as Map<String, dynamic>;
        ongoingBooking = OngoingBookingSummary(
          bookingId: b['id'] as String,
          serviceName: b['service_name'] as String? ?? '',
          vendorName: b['vendor_name'] as String? ?? '',
          status: b['status'] as String,
          scheduledAt: DateTime.parse(b['scheduled_at'] as String),
        );
      }

      return Right(HomeDataEntity(
        greeting: _getGreeting(),
        hasPrimeMembership: false,
        ongoingBooking: ongoingBooking,
        categories: categories.take(8).toList(),
        popularServices: popularServices,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
