import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/services/data_repository/repository_interface.dart';

part 'ride_dashboard_event.dart';
part 'ride_dashboard_state.dart';

class RideDashboardController
    extends Bloc<RideDashboardEvent, RideDashboardState> {
  RideDashboardController({required this.repositoryService})
      : super(const RideDashboardInitialState()) {
    on<SetRide>((event, emit) {
      ride = event.ride;
      user = event.user;
      isDriver = ride.driver.email == user.email;
    });
    on<FinishRide>(_finishRide);
    on<PassengerGiveUp>(_passengerGiveUp);
  }

  RepositoryInterface repositoryService;
  late RideData ride;
  late UsperUser user;
  late bool isDriver;

  void _finishRide(FinishRide event, Emitter<RideDashboardState> emit) async {
    emit(LoadingState());
    await repositoryService.deleteRide(ride.driver.email);
    emit(RideFinishedState());
  }

  void _passengerGiveUp(
      PassengerGiveUp event, Emitter<RideDashboardState> emit) async {
    // It may exist some logic to notify other members in the ride that this user has give up
    await repositoryService.deleteRideRequest(ride.driver.email, user.email);
    emit(RideFinishedState());
  }
}
