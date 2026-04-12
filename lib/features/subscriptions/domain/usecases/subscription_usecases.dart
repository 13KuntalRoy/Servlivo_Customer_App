import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/subscription_entity.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionsUseCase {
  final SubscriptionRepository repository;
  GetSubscriptionsUseCase(this.repository);

  Future<Either<Failure, List<SubscriptionEntity>>> call() =>
      repository.getSubscriptions();
}

class CreateSubscriptionParams {
  final String serviceId;
  final String frequency;
  final String addressId;

  const CreateSubscriptionParams({
    required this.serviceId,
    required this.frequency,
    required this.addressId,
  });
}

class CreateSubscriptionUseCase {
  final SubscriptionRepository repository;
  CreateSubscriptionUseCase(this.repository);

  Future<Either<Failure, SubscriptionEntity>> call(CreateSubscriptionParams params) =>
      repository.createSubscription(
        serviceId: params.serviceId,
        frequency: params.frequency,
        addressId: params.addressId,
      );
}

class PauseSubscriptionUseCase {
  final SubscriptionRepository repository;
  PauseSubscriptionUseCase(this.repository);

  Future<Either<Failure, SubscriptionEntity>> call(String id) =>
      repository.pauseSubscription(id);
}

class ResumeSubscriptionUseCase {
  final SubscriptionRepository repository;
  ResumeSubscriptionUseCase(this.repository);

  Future<Either<Failure, SubscriptionEntity>> call(String id) =>
      repository.resumeSubscription(id);
}

class CancelSubscriptionUseCase {
  final SubscriptionRepository repository;
  CancelSubscriptionUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) => repository.cancelSubscription(id);
}
