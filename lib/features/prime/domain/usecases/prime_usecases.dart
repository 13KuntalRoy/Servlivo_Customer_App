import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/prime_entity.dart';
import '../repositories/prime_repository.dart';

class GetPrimePlansUseCase {
  final PrimeRepository repository;
  GetPrimePlansUseCase(this.repository);

  Future<Either<Failure, List<PrimePlanEntity>>> call() => repository.getPlans();
}

class SubscribePrimeUseCase {
  final PrimeRepository repository;
  SubscribePrimeUseCase(this.repository);

  Future<Either<Failure, PrimeMembershipEntity>> call(String planId) =>
      repository.subscribe(planId);
}

class GetPrimeMembershipUseCase {
  final PrimeRepository repository;
  GetPrimeMembershipUseCase(this.repository);

  Future<Either<Failure, PrimeMembershipEntity?>> call() => repository.getMembership();
}
