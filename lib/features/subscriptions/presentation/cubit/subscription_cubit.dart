import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/subscription_entity.dart';
import '../../domain/usecases/subscription_usecases.dart';

part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final GetSubscriptionsUseCase _getSubscriptions;
  final PauseSubscriptionUseCase _pause;
  final ResumeSubscriptionUseCase _resume;
  final CancelSubscriptionUseCase _cancel;

  SubscriptionCubit({
    required GetSubscriptionsUseCase getSubscriptions,
    required PauseSubscriptionUseCase pause,
    required ResumeSubscriptionUseCase resume,
    required CancelSubscriptionUseCase cancel,
  })  : _getSubscriptions = getSubscriptions,
        _pause = pause,
        _resume = resume,
        _cancel = cancel,
        super(const SubscriptionInitial());

  Future<void> load() async {
    emit(const SubscriptionLoading());
    final result = await _getSubscriptions();
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subs) => emit(SubscriptionLoaded(subs)),
    );
  }

  Future<void> pause(String id) async {
    final result = await _pause(id);
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (_) => load(),
    );
  }

  Future<void> resume(String id) async {
    final result = await _resume(id);
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (_) => load(),
    );
  }

  Future<void> cancel(String id) async {
    final result = await _cancel(id);
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (_) => load(),
    );
  }
}
