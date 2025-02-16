import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:usper/constants/datatbase_tables.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';
import 'package:usper/utils/database/insert_data.dart';
import 'package:usper/utils/displayable_address.dart';

part 'ride_creation_event.dart';
part 'ride_creation_state.dart';

class RideCreationController
    extends Bloc<RideCreationEvent, RideCreationState> {
  RideCreationController() : super(InitialRideCreationState()) {
    on<SetDepartureTime>(_setDepartureTime);
    on<SetOriginData>(_setOriginData);
    on<SetDestinationData>(_setDestinationData);
    on<VehicleRideChosed>(_setRideVehicle);
    on<RideCreationFinished>(_createRide);
    on<RideCanceled>(_clearData);
  }

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
    print(event.locationData.addressData['country']);

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
      await _insertRideDatabase(event.driver!.email);
      emit(const RideCreated());
    }
  }

  void _clearData(RideCanceled event, Emitter<RideCreationState> emit) {
    departTime = null;
    originData = null;
    destData = null;
    vehicle = null;
    emit(RideDataCleared());
  }

  Future<void> _insertRideDatabase(final String driverEmail) async {
    await insertData(DatabaseTables.rides, {
      "driver_email": driverEmail,
      "vehicle_plate": vehicle!.licensePlate,
      "origin_name": originData!.address,
      "destination_name": destData!.address,
      "origin_latitude": originData!.latLong.latitude,
      "origin_longitude": originData!.latLong.longitude,
      "dest_latitude": destData!.latLong.latitude,
      "dest_longitude": destData!.latLong.longitude,
      "depart_time": departTime!.toIso8601String()
    });
  }
}
