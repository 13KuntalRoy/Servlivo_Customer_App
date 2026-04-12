import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../domain/entities/payment_entity.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/initiate_payment_usecase.dart';
import '../../domain/usecases/verify_payment_usecase.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final InitiatePaymentUseCase _initiatePayment;
  final VerifyPaymentUseCase _verifyPayment;
  final GetTransactionsUseCase _getTransactions;
  late final Razorpay _razorpay;

  PaymentBloc({
    required InitiatePaymentUseCase initiatePayment,
    required VerifyPaymentUseCase verifyPayment,
    required GetTransactionsUseCase getTransactions,
  })  : _initiatePayment = initiatePayment,
        _verifyPayment = verifyPayment,
        _getTransactions = getTransactions,
        super(const PaymentInitial()) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    on<PaymentInitiated>(_onInitiated);
    on<PaymentSucceeded>(_onSucceeded);
    on<PaymentFailed>(_onFailed);
    on<TransactionsLoaded>(_onLoadTransactions);
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    add(PaymentSucceeded(
      orderId: response.orderId ?? '',
      paymentId: response.paymentId ?? '',
      signature: response.signature ?? '',
    ));
  }

  void _handleError(PaymentFailureResponse response) {
    add(PaymentFailed(response.message ?? 'Payment failed'));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    add(PaymentFailed('External wallet: ${response.walletName}'));
  }

  Future<void> _onInitiated(PaymentInitiated event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());
    final result = await _initiatePayment(event.bookingId);
    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (order) {
        final options = {
          'key': order.keyId,
          'amount': (order.amount * 100).toInt(),
          'currency': order.currency,
          'order_id': order.orderId,
          'name': 'Servlivo',
          'description': 'Service Payment',
          'prefill': {'contact': '', 'email': ''},
        };
        _razorpay.open(options);
        emit(PaymentProcessing(order));
      },
    );
  }

  Future<void> _onSucceeded(PaymentSucceeded event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());
    final result = await _verifyPayment(VerifyPaymentParams(
      razorpayOrderId: event.orderId,
      razorpayPaymentId: event.paymentId,
      razorpaySignature: event.signature,
    ));
    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (payment) => emit(PaymentCompleted(payment)),
    );
  }

  void _onFailed(PaymentFailed event, Emitter<PaymentState> emit) {
    emit(PaymentError(event.reason));
  }

  Future<void> _onLoadTransactions(TransactionsLoaded event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());
    final result = await _getTransactions();
    result.fold(
      (failure) => emit(PaymentError(failure.message)),
      (transactions) => emit(TransactionsState(transactions)),
    );
  }

  @override
  Future<void> close() {
    _razorpay.clear();
    return super.close();
  }
}
