import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/services/data_repository/repository_interface.dart';

part 'ride_dashboard_event.dart';
part 'ride_dashboard_state.dart';

class RideDashboardController
    extends Bloc<RideDashboardEvent, RideDashboardState> {
  RideDashboardController({required this.repositoryService})
      : super(const RideDashboardInitialState()) {
    on<RideStarted>((event, emit) => ride = event.ride);
    on<FinishRide>(_finishRide);
  }

  RepositoryInterface repositoryService;
  late RideData ride;

  void _finishRide(FinishRide event, Emitter<RideDashboardState> emit) async {
    emit(LoadingState());
    await repositoryService.deleteRide(ride.driver.email);
    emit(RideFinishedState());
  }
}
