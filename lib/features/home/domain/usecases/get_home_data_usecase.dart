import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/home_data_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeDataUseCase {
  final HomeRepository repository;
  GetHomeDataUseCase(this.repository);

  Future<Either<Failure, HomeDataEntity>> call() => repository.getHomeData();
}
