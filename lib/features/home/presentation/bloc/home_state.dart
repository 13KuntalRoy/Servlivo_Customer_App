part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final HomeDataEntity data;
  const HomeLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
