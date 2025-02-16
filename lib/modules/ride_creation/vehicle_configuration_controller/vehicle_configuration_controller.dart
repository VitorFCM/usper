import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:usper/constants/datatbase_tables.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';
import 'package:usper/modules/ride_creation/ride_creation_controller/ride_creation_controller.dart';
import 'package:usper/utils/database/fetch_data.dart';
import 'package:usper/utils/database/insert_data.dart';
import 'package:usper/utils/vehicles_requests/get_reference_table.dart';
import 'package:usper/utils/vehicles_requests/get_vehicles_makers.dart';
import 'package:usper/utils/vehicles_requests/get_vehicles_models.dart';

part 'vehicle_configuration_event.dart';
part 'vehicle_configuration_state.dart';

class VehicleConfigurationController
    extends Bloc<VehicleConfigurationEvent, VehicleConfigurationState> {
  VehicleConfigurationController(this.rideCreationController)
      : super(const SeatsCounterNewValue(0)) {
    on<SeatsCounterIncreased>(_increaseSeatsCounter);
    on<SeatsCounterDecreased>(_decreaseSeatsCounter);
    on<SetVehicleColor>(_setVehicleColor);
    on<VehicleDataReady>(_createVehicle);
    on<RetrieveVehiclesList>(_retrieveVehiclesList);
    on<VehicleChosed>(_setRideVehicle);
    on<VehicleTypeSwitched>(_retrieveVehicleMakers);
    on<VehicleMakerSelected>(_retrieveVehicleModels);
    on<VehicleModelSelected>(_setVehicleModel);
  }

  RideCreationController rideCreationController;

  int _seatsCounter = 0;
  final int _maxNumberOfSeats =
      4; //In the future, a better implementation shoud be proposed
  Vehicle? vehicle;
  String? vehicleColorName;
  Map<String, int?>? carsMakers;
  Map<String, int?>? motorcyclesMakers;
  late bool isCar;
  String? vehicleModel;

  void _increaseSeatsCounter(
      SeatsCounterIncreased event, Emitter<VehicleConfigurationState> emit) {
    if (_seatsCounter == _maxNumberOfSeats) {
      emit(VehicleConfigurationStateError(
          "O número máximo de vagas desse veículo é ${_maxNumberOfSeats}"));
    } else {
      _seatsCounter++;
      emit(SeatsCounterNewValue(_seatsCounter));
    }
  }

  void _decreaseSeatsCounter(
      SeatsCounterDecreased event, Emitter<VehicleConfigurationState> emit) {
    if (_seatsCounter == 0) {
      emit(const VehicleConfigurationStateError(
          "Não é possível ter um valor negativo de assentos"));
    } else {
      _seatsCounter--;
      emit(SeatsCounterNewValue(_seatsCounter));
    }
  }

  void _setVehicleColor(
      SetVehicleColor event, Emitter<VehicleConfigurationState> emit) {
    vehicleColorName = event.colorName;
    emit(VehicleColorSetted(event.vehicleColor, event.colorName));
  }

  void _createVehicle(
      VehicleDataReady event, Emitter<VehicleConfigurationState> emit) async {
    UsperUser? driver = event.driver;

    if (_seatsCounter == 0) {
      emit(const VehicleConfigurationStateError(
          "O número de vagas deve ser aumentado"));
    } else if (event.vehiclePlate.isEmpty) {
      emit(const VehicleConfigurationStateError(
          "É necessário fornecer a placa do veículo"));
    } else if (vehicleColorName?.isEmpty ?? true) {
      emit(const VehicleConfigurationStateError(
          "É necessário fornecer a cor do veículo"));
    } else if (vehicleModel?.isEmpty ?? true) {
      emit(const VehicleConfigurationStateError(
          "É necessário fornecer o modelo do veículo"));
    } else if (driver == null) {
      emit(const VehicleConfigurationStateError(
          "Ocorreu um erro com o seu login, por favor feche o aplicativo e tente novamente"));
    } else {
      vehicle = Vehicle(
          _seatsCounter, vehicleModel!, event.vehiclePlate, vehicleColorName!);
      await _insertVehicleDatabase(vehicle!, driver);
      _clearData();
      rideCreationController.add(VehicleRideChosed(vehicle!));
      emit(VehicleDefined());
    }
  }

  Future<void> _retrieveVehiclesList(RetrieveVehiclesList event,
      Emitter<VehicleConfigurationState> emit) async {
    List<Map<String, dynamic>> rawList = await fetchData(
        DatabaseTables.vehicles, {"owner_email": event.driverEmail});

    emit(VehiclesListRetrieved(rawList
        .map((value) => Vehicle(
            value["seats"], value["model"], value["plate"], value["color"]))
        .toList()));
  }

  void _setRideVehicle(
      VehicleChosed event, Emitter<VehicleConfigurationState> emit) {
    vehicle = event.vehicle;

    rideCreationController.add(VehicleRideChosed(vehicle!));

    emit(VehicleDefined());
  }

  Future<void> _retrieveVehicleMakers(VehicleTypeSwitched event,
      Emitter<VehicleConfigurationState> emit) async {
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

  Future<void> _retrieveVehicleModels(VehicleMakerSelected event,
      Emitter<VehicleConfigurationState> emit) async {
    int? makerCode = isCar
        ? carsMakers![event.vehicleMaker]
        : motorcyclesMakers![event.vehicleMaker];

    if (makerCode == null) {
      emit(const VehicleConfigurationStateError(
          "Não foi possível obter a lista de modelos. Vamos utilizar apenas o fabricante"));
    } else {
      emit(VehicleModelsRetrieved(await getVehiclesModels(
          makerCode, await getReferenceTable(), isCar ? 1 : 2)));
    }
  }

  void _setVehicleModel(
      VehicleModelSelected event, Emitter<VehicleConfigurationState> emit) {
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
    vehicleColorName = null;
    vehicleModel = null;
  }
}
