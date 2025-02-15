import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:usper/core/classes/class_vehicle.dart';
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
  }

  DateTime? departTime;
  PickedData? originData;
  PickedData? destData;
  Vehicle? vehicle;
  String? vehicleColorName;
  Map<String, int?>? carsMakers;
  Map<String, int?>? motorcyclesMakers;
  late bool isCar;
  String? vehicleModel;

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
}
