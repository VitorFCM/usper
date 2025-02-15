import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:usper/constants/datatbase_tables.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';
import 'package:usper/utils/database/fetch_data.dart';
import 'package:usper/utils/database/insert_data.dart';
import 'package:usper/utils/displayable_address.dart';
import 'package:usper/utils/vehicles_requests/get_reference_table.dart';
import 'package:usper/utils/vehicles_requests/get_vehicles_makers.dart';
import 'package:usper/utils/vehicles_requests/get_vehicles_models.dart';

part 'ride_creation_event.dart';
part 'ride_creation_state.dart';

class RideCreationController
    extends Bloc<RideCreationEvent, RideCreationState> {
  RideCreationController() : super(const SeatsCounterNewValue(0)) {
    on<SeatsCounterIncreased>(_increaseSeatsCounter);
    on<SeatsCounterDecreased>(_decreaseSeatsCounter);
    on<SetDepartureTime>(_setDepartureTime);
    on<SetOriginData>(_setOriginData);
    on<SetDestinationData>(_setDestinationData);
    on<SetVehicleColor>(_setVehicleColor);
    on<VehicleDataReady>(_verifyVehicleData);
    on<RetrieveVehiclesList>(_retrieveVehiclesList);
    on<VehicleChosed>(_setRideVehicle);
    on<VehicleTypeSwitched>(_retrieveVehicleMakers);
    on<VehicleMakerSelected>(_retrieveVehicleModels);
    on<VehicleModelSelected>(_setVehicleModel);
  }

  int _seatsCounter = 0;
  final int _maxNumberOfSeats =
      4; //In the future, a better implementation shoud be proposed
  DateTime? departTime;
  PickedData? originData;
  PickedData? destData;
  Vehicle? vehicle;
  String? vehicleColorName;
  Map<String, int?>? carsMakers;
  Map<String, int?>? motorcyclesMakers;
  late bool isCar;
  String? vehicleModel;

  void _increaseSeatsCounter(
      SeatsCounterIncreased event, Emitter<RideCreationState> emit) {
    if (_seatsCounter == _maxNumberOfSeats) {
      emit(RideCreationStateError(
          "O número máximo de vagas desse veículo é ${_maxNumberOfSeats}"));
    } else {
      _seatsCounter++;
      emit(SeatsCounterNewValue(_seatsCounter));
    }
  }

  void _decreaseSeatsCounter(
      SeatsCounterDecreased event, Emitter<RideCreationState> emit) {
    if (_seatsCounter == 0) {
      emit(const RideCreationStateError(
          "Não é possível ter um valor negativo de assentos"));
    } else {
      _seatsCounter--;
      emit(SeatsCounterNewValue(_seatsCounter));
    }
  }

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

  void _setVehicleColor(
      SetVehicleColor event, Emitter<RideCreationState> emit) {
    vehicleColorName = event.colorName;
    emit(VehicleColorSetted(event.vehicleColor, event.colorName));
  }

  void _verifyVehicleData(
      VehicleDataReady event, Emitter<RideCreationState> emit) async {
    UsperUser? driver = event.driver;

    if (_seatsCounter == 0) {
      emit(
          const RideCreationStateError("O número de vagas deve ser aumentado"));
    } else if (event.vehiclePlate.isEmpty) {
      emit(const RideCreationStateError(
          "É necessário fornecer a placa do veículo"));
    } else if (vehicleColorName?.isEmpty ?? true) {
      emit(const RideCreationStateError(
          "É necessário fornecer a cor do veículo"));
    } else if (vehicleModel?.isEmpty ?? true) {
      emit(const RideCreationStateError(
          "É necessário fornecer o modelo do veículo"));
    } else if (driver == null) {
      emit(const RideCreationStateError(
          "Ocorreu um erro com o seu login, por favor feche o aplicativo e tente novamente"));
    } else {
      vehicle = Vehicle(
          _seatsCounter, vehicleModel!, event.vehiclePlate, vehicleColorName!);
      await _insertVehicleDatabase(vehicle!, driver);
      _clearData();
      emit(RideVehicleDefined(vehicle!));
    }
  }

  Future<void> _retrieveVehiclesList(
      RetrieveVehiclesList event, Emitter<RideCreationState> emit) async {
    List<Map<String, dynamic>> rawList = await fetchData(
        DatabaseTables.vehicles, {"owner_email": event.driverEmail});

    emit(VehiclesListRetrieved(rawList
        .map((value) => Vehicle(
            value["seats"], value["model"], value["plate"], value["color"]))
        .toList()));
  }

  void _setRideVehicle(VehicleChosed event, Emitter<RideCreationState> emit) {
    vehicle = event.vehicle;

    emit(RideVehicleDefined(vehicle!));
  }

  Future<void> _retrieveVehicleMakers(
      VehicleTypeSwitched event, Emitter<RideCreationState> emit) async {
    isCar = event.isCar;
    Map<String, int?>? vehiclesMakers = isCar ? carsMakers : motorcyclesMakers;

    vehiclesMakers ??=
        await getVehiclesMakers(await getReferenceTable(), isCar ? 1 : 2);

    if (isCar) {
      carsMakers = vehiclesMakers;
    } else {
      motorcyclesMakers = vehiclesMakers;
    }

    emit(VehicleMakersRetrieved(
        isCar, vehiclesMakers?.keys.toList() ?? ["Sem marcas"]));
  }

  Future<void> _retrieveVehicleModels(
      VehicleMakerSelected event, Emitter<RideCreationState> emit) async {
    int? makerCode = isCar
        ? carsMakers![event.vehicleMaker]
        : motorcyclesMakers![event.vehicleMaker];

    if (makerCode == null) {
      emit(const RideCreationStateError(
          "Não foi possível obter a lista de modelos. Vamos utilizar apenas o fabricante"));
    } else {
      emit(VehicleModelsRetrieved(await getVehiclesModels(
          makerCode, await getReferenceTable(), isCar ? 1 : 2)));
    }
  }

  void _setVehicleModel(
      VehicleModelSelected event, Emitter<RideCreationState> emit) {
    vehicleModel = event.vehicleModel;
    emit(VehicleModelDefined());
  }

  Future<void> _insertVehicleDatabase(Vehicle vehicle, UsperUser user) async {
    try {
      await insertData(DatabaseTables.vehicles, {
        "plate": vehicle.licensePlate,
        "seats": vehicle.seats,
        "color": vehicle.color,
        "model": vehicle.model,
        "owner_email": user.email
      });
    } on PostgrestException catch (e) {
      if (e.code != null && "23505".compareTo(e.code!) != 0) rethrow;
    }
  }

  void _clearData() {
    _seatsCounter = 0;
    departTime = null;
    originData = null;
    destData = null;
    vehicleColorName = null;
    vehicleModel = null;
  }
}
