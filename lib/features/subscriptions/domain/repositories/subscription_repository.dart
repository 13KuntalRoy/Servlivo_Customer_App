import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<SubscriptionEntity>>> getSubscriptions();
  Future<Either<Failure, SubscriptionEntity>> createSubscription({
    required String serviceId,
    required String frequency,
    required String addressId,
  });
  Future<Either<Failure, SubscriptionEntity>> pauseSubscription(String id);
  Future<Either<Failure, SubscriptionEntity>> resumeSubscription(String id);
  Future<Either<Failure, void>> cancelSubscription(String id);
}
