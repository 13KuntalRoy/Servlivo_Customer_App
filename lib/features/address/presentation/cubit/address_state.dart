part of 'address_cubit.dart';

sealed class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  const AddressLoading();
}

class AddressLoaded extends AddressState {
  final List<AddressEntity> addresses;

  const AddressLoaded(this.addresses);

  @override
  List<Object> get props => [addresses];
}

class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object> get props => [message];
}
