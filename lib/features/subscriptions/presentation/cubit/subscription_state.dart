part of 'subscription_cubit.dart';

sealed class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionLoaded extends SubscriptionState {
  final List<SubscriptionEntity> subscriptions;
  const SubscriptionLoaded(this.subscriptions);

  @override
  List<Object> get props => [subscriptions];
}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);

  @override
  List<Object> get props => [message];
}
