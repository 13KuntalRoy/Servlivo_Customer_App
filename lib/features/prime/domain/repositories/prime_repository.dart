import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/prime_entity.dart';

abstract class PrimeRepository {
  Future<Either<Failure, List<PrimePlanEntity>>> getPlans();
  Future<Either<Failure, PrimeMembershipEntity>> subscribe(String planId);
  Future<Either<Failure, PrimeMembershipEntity?>> getMembership();
}
