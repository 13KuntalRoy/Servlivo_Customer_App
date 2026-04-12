import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/prime_entity.dart';
import '../../domain/usecases/prime_usecases.dart';

part 'prime_state.dart';

class PrimeCubit extends Cubit<PrimeState> {
  final GetPrimePlansUseCase _getPlans;
  final SubscribePrimeUseCase _subscribe;
  final GetPrimeMembershipUseCase _getMembership;

  PrimeCubit({
    required GetPrimePlansUseCase getPlans,
    required SubscribePrimeUseCase subscribe,
    required GetPrimeMembershipUseCase getMembership,
  })  : _getPlans = getPlans,
        _subscribe = subscribe,
        _getMembership = getMembership,
        super(const PrimeInitial());

  Future<void> load() async {
    emit(const PrimeLoading());
    final plansResult = await _getPlans();
    final membershipResult = await _getMembership();

    final plans = plansResult.fold((_) => <PrimePlanEntity>[], (p) => p);
    final membership = membershipResult.fold((_) => null, (m) => m);

    if (plansResult.isLeft()) {
      emit(PrimeError(plansResult.fold((f) => f.message, (_) => '')));
    } else {
      emit(PrimeLoaded(plans: plans, membership: membership));
    }
  }

  Future<void> subscribe(String planId) async {
    final current = state;
    if (current is! PrimeLoaded) return;
    emit(const PrimeLoading());
    final result = await _subscribe(planId);
    result.fold(
      (failure) => emit(PrimeError(failure.message)),
      (membership) => emit(PrimeLoaded(plans: current.plans, membership: membership)),
    );
  }
}
