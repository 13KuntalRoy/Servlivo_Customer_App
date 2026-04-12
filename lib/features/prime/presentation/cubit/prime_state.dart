part of 'prime_cubit.dart';

sealed class PrimeState extends Equatable {
  const PrimeState();

  @override
  List<Object?> get props => [];
}

class PrimeInitial extends PrimeState {
  const PrimeInitial();
}

class PrimeLoading extends PrimeState {
  const PrimeLoading();
}

class PrimeLoaded extends PrimeState {
  final List<PrimePlanEntity> plans;
  final PrimeMembershipEntity? membership;

  const PrimeLoaded({required this.plans, this.membership});

  bool get isMember => membership?.isActive == true;

  @override
  List<Object?> get props => [plans, membership];
}

class PrimeError extends PrimeState {
  final String message;
  const PrimeError(this.message);

  @override
  List<Object> get props => [message];
}
