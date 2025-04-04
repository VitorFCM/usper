import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';
import 'package:usper/services/data_repository/repository_interface.dart';
import 'package:usper/utils/displayable_address.dart';

part 'ride_creation_event.dart';
part 'ride_creation_state.dart';

class RideCreationController
    extends Bloc<RideCreationEvent, RideCreationState> {
  RideCreationController({required this.repositoryService})
      : super(InitialRideCreationState()) {
    on<SetDepartureTime>(_setDepartureTime);
    on<SetOriginData>(_setOriginData);
    on<SetDestinationData>(_setDestinationData);
    on<VehicleRideChosed>(_setRideVehicle);
    on<RideCreationFinished>(_createRide);
    on<RideCanceled>(_clearData);
  }

  RepositoryInterface repositoryService;

  DateTime? departTime;
  PickedData? originData;
  PickedData? destData;
  Vehicle? vehicle;

  void _setDepartureTime(
      SetDepartureTime event, Emitter<RideCreationState> emit) {
    departTime = event.departTime;
    emit(DepartureTimeSetted(departTime!));
  }

  void _setOriginData(SetOriginData event, Emitter<RideCreationState> emit) {
    print(event.locationData.latLong.latitude);
    print(event.locationData.latLong.longitude);
    print(event.locationData.addressData);
    print(event.locationData.address);

    originData = event.locationData;

    emit(OriginLocationSetted(displayableAddress(originData!.addressData),
        _latLongToLatLng(originData!.latLong)));
  }

  void _setDestinationData(
      SetDestinationData event, Emitter<RideCreationState> emit) {
    destData = event.locationData;
    emit(DestLocationSetted(displayableAddress(destData!.addressData),
        _latLongToLatLng(destData!.latLong)));
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
      RideData ride = _createRideData(event.driver!);
      await repositoryService.insertRide(ride);
      emit(RideCreated(ride: ride));
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
        driver: driver);
  }

  void _clearData(RideCanceled event, Emitter<RideCreationState> emit) {
    departTime = null;
    originData = null;
    destData = null;
    vehicle = null;
    emit(RideDataCleared());
  }
}
