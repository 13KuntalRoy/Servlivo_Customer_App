import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/home_data_entity.dart';
import '../../domain/usecases/get_home_data_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeDataUseCase _getHomeData;

  HomeBloc({required GetHomeDataUseCase getHomeData})
      : _getHomeData = getHomeData,
        super(const HomeInitial()) {
    on<HomeDataRequested>(_onDataRequested);
  }

  Future<void> _onDataRequested(
    HomeDataRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    final result = await _getHomeData();
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (data) => emit(HomeLoaded(data)),
    );
  }
}
