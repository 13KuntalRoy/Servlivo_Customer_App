import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/address_entity.dart';
import '../../domain/usecases/create_address_usecase.dart';
import '../../domain/usecases/delete_address_usecase.dart';
import '../../domain/usecases/get_addresses_usecase.dart';
import '../../domain/usecases/update_address_usecase.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final GetAddressesUseCase _getAddresses;
  final CreateAddressUseCase _createAddress;
  final UpdateAddressUseCase _updateAddress;
  final DeleteAddressUseCase _deleteAddress;

  AddressCubit({
    required GetAddressesUseCase getAddresses,
    required CreateAddressUseCase createAddress,
    required UpdateAddressUseCase updateAddress,
    required DeleteAddressUseCase deleteAddress,
  })  : _getAddresses = getAddresses,
        _createAddress = createAddress,
        _updateAddress = updateAddress,
        _deleteAddress = deleteAddress,
        super(const AddressInitial());

  Future<void> loadAddresses() async {
    emit(const AddressLoading());
    final result = await _getAddresses();
    result.fold(
      (f) => emit(AddressError(f.message)),
      (addresses) => emit(AddressLoaded(addresses)),
    );
  }

  Future<void> createAddress(CreateAddressParams params) async {
    final result = await _createAddress(params);
    result.fold(
      (f) => emit(AddressError(f.message)),
      (address) {
        final current = state is AddressLoaded ? (state as AddressLoaded).addresses : <AddressEntity>[];
        emit(AddressLoaded([...current, address]));
      },
    );
  }

  Future<void> updateAddress(String id, Map<String, dynamic> data) async {
    final result = await _updateAddress(id: id, data: data);
    result.fold(
      (f) => emit(AddressError(f.message)),
      (_) => loadAddresses(),
    );
  }

  Future<void> deleteAddress(String id) async {
    final result = await _deleteAddress(id);
    result.fold(
      (f) => emit(AddressError(f.message)),
      (_) {
        if (state is AddressLoaded) {
          final updated = (state as AddressLoaded)
              .addresses
              .where((a) => a.id != id)
              .toList();
          emit(AddressLoaded(updated));
        }
      },
    );
  }
}
