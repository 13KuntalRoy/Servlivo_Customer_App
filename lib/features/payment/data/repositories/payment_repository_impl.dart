import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remote;
  final NetworkInfo networkInfo;

  PaymentRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, PaymentOrderEntity>> initiatePayment(String bookingId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final data = await remote.initiatePayment(bookingId);
      return Right(PaymentOrderModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final data = await remote.verifyPayment({
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      });
      return Right(PaymentModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getTransactions() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final list = await remote.getTransactions();
      return Right(list.map(PaymentModel.fromJson).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> requestRefund(String paymentId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final data = await remote.requestRefund(paymentId);
      return Right(PaymentModel.fromJson(data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
