import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';
import 'package:usper/services/data_repository/repository_exceptions.dart';
import 'package:usper/services/data_repository/repository_interface.dart';
import 'package:usper/services/map_service/map_interface.dart';
import 'package:usper/services/map_service/map_service.dart';
import 'package:usper/utils/displayable_address.dart';

part 'ride_creation_event.dart';
part 'ride_creation_state.dart';

class RideCreationController
    extends Bloc<RideCreationEvent, RideCreationState> {
  RideCreationController(
      {required this.repositoryService, required this.mapService})
      : super(InitialRideCreationState()) {
    on<SetDepartureTime>(_setDepartureTime);
    on<SetOriginData>(_setOriginData);
    on<SetDestinationData>(_setDestinationData);
    on<VehicleRideChosed>(_setRideVehicle);
    on<RideCreationFinished>(_createRide);
    on<RideCanceled>(_clearData);
    on<DeleteOldRideAndCreateNew>(_deleteOldRideAndCreateNew);
    on<KeepOldRide>(((event, emit) => emit(RideCreated(ride: event.oldRide))));
  }

  RepositoryInterface repositoryService;
  MapInterface mapService;

  DateTime? departTime;
  PickedData? originData;
  PickedData? destData;
  List<LatLng>? route;
  Vehicle? vehicle;

  RideData? finalRide;

  void _setDepartureTime(
      SetDepartureTime event, Emitter<RideCreationState> emit) {
    departTime = event.departTime;
    emit(DepartureTimeSetState(departTime!));
  }

  void _setOriginData(
      SetOriginData event, Emitter<RideCreationState> emit) async {
    print(event.locationData.latLong.latitude);
    print(event.locationData.latLong.longitude);
    print(event.locationData.addressData);
    print(event.locationData.address);

    originData = event.locationData;

    if (destData != null) {
      route = await mapService.getRoute(_latLongToLatLng(originData!.latLong),
          _latLongToLatLng(destData!.latLong));
    }

    emit(OriginLocationSetState(displayableAddress(originData!.addressData),
        _latLongToLatLng(originData!.latLong),
        route: route));
  }

  void _setDestinationData(
      SetDestinationData event, Emitter<RideCreationState> emit) async {
    destData = event.locationData;

    if (originData != null) {
      route = await mapService.getRoute(_latLongToLatLng(originData!.latLong),
          _latLongToLatLng(destData!.latLong));
    }

    emit(DestLocationSetState(displayableAddress(destData!.addressData),
        _latLongToLatLng(destData!.latLong),
        route: route));
  }

  LatLng _latLongToLatLng(LatLong location) {
    return LatLng(location.latitude, location.longitude);
  }

  void _setRideVehicle(
      VehicleRideChosed event, Emitter<RideCreationState> emit) {
    vehicle = event.vehicle;

    emit(RideVehicleDefined(vehicle!));
  }

  void _createRide(
      RideCreationFinished event, Emitter<RideCreationState> emit) async {
    if (originData == null) {
      emit(const RideCreationStateError("O local de origem deve ser definido"));
    } else if (destData == null) {
      emit(
          const RideCreationStateError("O local de destino deve ser definido"));
    } else if (departTime == null) {
      emit(const RideCreationStateError(
          "O horário de partida deve ser definido"));
    } else if (vehicle == null) {
      emit(const RideCreationStateError("O veículo deve ser definido"));
    } else if (event.driver == null) {
      emit(const RideCreationStateError(
          "Ocorreu um erro com o seu login, por favor feche o aplicativo e tente novamente"));
    } else {
      finalRide = _createRideData(event.driver!);
      try {
        await repositoryService.insertRide(finalRide!);
        emit(RideCreated(ride: finalRide!));
      } on DriverAlreadyHaveARideException {
        RideData? oldRide =
            await repositoryService.getRide(finalRide!.driver.email);
        if (oldRide != null) {
          emit(DriverAlreadyHaveARide(oldRide: oldRide));
        } else {
          add(DeleteOldRideAndCreateNew(oldRide: finalRide!));
        }
      }
    }
  }

  void _deleteOldRideAndCreateNew(
      DeleteOldRideAndCreateNew event, Emitter<RideCreationState> emit) async {
    try {
      await repositoryService.deleteRide(event.oldRide.driver.email);
      await repositoryService.insertRide(finalRide!);
      emit(RideCreated(ride: finalRide!));
    } catch (e) {
      emit(RideCreationStateError(e.toString()));
    }
  }

  RideData _createRideData(UsperUser driver) {
    return RideData(
        originName: displayableAddress(originData!.addressData),
        destName: displayableAddress(destData!.addressData),
        originCoord:
            LatLng(originData!.latLong.latitude, originData!.latLong.longitude),
        destCoord:
            LatLng(destData!.latLong.latitude, destData!.latLong.longitude),
        departTime: departTime!,
        vehicle: vehicle!,
        driver: driver,
        route: route);
  }

  void _clearData(RideCanceled event, Emitter<RideCreationState> emit) {
    departTime = null;
    originData = null;
    destData = null;
    vehicle = null;
    route = null;
    emit(RideDataCleared());
  }
}
