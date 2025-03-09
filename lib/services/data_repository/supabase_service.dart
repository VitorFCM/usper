import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:usper/constants/database_event_type.dart';
import 'package:usper/constants/datatbase_tables.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';
import 'package:usper/services/data_repository/repository_interface.dart';
import 'package:usper/utils/database/fetch_data.dart';
import 'package:usper/utils/database/insert_data.dart';

class SupabaseService implements RepositoryInterface {
  final StreamController<MapEntry<DatabaseEventType, RideData>>
      _rideDataStreamController =
      StreamController<MapEntry<DatabaseEventType, RideData>>.broadcast();

  final supabase = Supabase.instance.client;

  Map<String, RideData>? allAvailableRides;

  SupabaseService() {
    _init();
  }

  @override
  Future<void> insertUser(UsperUser user) async {
    try {
      await insertData(DatabaseTables.users, {
        "email": user.email,
        "image_link": user.imageLink,
        "first_name": user.firstName,
        "last_name": user.lastName
      });
    } on PostgrestException catch (e) {
      if (e.code != null && "23505".compareTo(e.code!) != 0) rethrow;
    }
  }

  @override
  Future<void> insertVehicle(Vehicle vehicle, UsperUser user) async {
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

  @override
  Future<List<Vehicle>> fetchVehiclesByOwner(String ownerId) async {
    return _fetchVehiclesByMatchCondition({"owner_email": ownerId});
  }

  @override
  Future<void> insertRide(final String driverId, DateTime departTime,
      var originData, var destData, Vehicle vehicle) async {
    await insertData(DatabaseTables.rides, {
      "driver_email": driverId,
      "vehicle_plate": vehicle.licensePlate,
      "origin_name": originData.address,
      "destination_name": destData.address,
      "origin_latitude": originData.latitude,
      "origin_longitude": originData.longitude,
      "dest_latitude": destData.latitude,
      "dest_longitude": destData.longitude,
      "depart_time": departTime.toIso8601String()
    });
  }

  @override
  Future<Map<String, RideData>> fetchAllAvaiableRides() async {
    if (allAvailableRides != null) {
      return allAvailableRides!;
    }

    List<Map<String, dynamic>> rawList =
        await fetchData(DatabaseTables.rides, {"started": false});

    return {
      for (var record in rawList)
        record["driver_email"]: await _createRideDataByRawRecord(record)
    };
  }

  @override
  Stream<MapEntry<DatabaseEventType, RideData>> rideDataStream() {
    return _rideDataStreamController.stream;
  }

  Future<List<Vehicle>> _fetchVehiclesByMatchCondition(
      Map<String, Object> matchCondition) async {
    List<Map<String, dynamic>> rawList =
        await fetchData(DatabaseTables.vehicles, matchCondition);

    return rawList
        .map((value) => Vehicle(
            value["seats"], value["model"], value["plate"], value["color"]))
        .toList();
  }

  Future<UsperUser> _fetchDriver(final String driverId) async {
    List<Map<String, dynamic>> rawList =
        await fetchData(DatabaseTables.users, {"email": driverId});

    return rawList
        .map((value) => UsperUser(value["email"], value["first_name"],
            value["last_name"], value["course"], value["image_link"]))
        .first;
  }

  Future<RideData> _createRideDataByRawRecord(
      Map<String, dynamic> record) async {
    // It may exist more performatic approaches wich doesn't rely on
    // multiple requests as the code bellow is doing. Maybe, only one request
    // with a join operation between tables rides, users and vehicles could be done.

    List<Vehicle> vehiclesList = await _fetchVehiclesByMatchCondition(
        {"plate": record["vehicle_plate"]});

    UsperUser driver = await _fetchDriver(record["driver_email"]);

    return RideData(
        driver: driver,
        originName: record["origin_name"],
        destName: record["destination_name"],
        originCoord:
            LatLng(record["origin_latitude"], record["origin_longitude"]),
        destCoord: LatLng(record["dest_latitude"], record["dest_longitude"]),
        departTime: DateTime.parse(record["depart_time"]),
        vehicle: vehiclesList[0]);
  }

  Future<void> _init() async {
    allAvailableRides = await fetchAllAvaiableRides();

    supabase
        .channel("public:${DatabaseTables.rides.name}")
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: DatabaseTables.rides.name,
            callback: (payload) async {
              print(payload);
              _rideDataStreamController
                  .add(await _payloadToStreamMapEntry(payload));
            })
        .subscribe();
  }

  Future<MapEntry<DatabaseEventType, RideData>> _payloadToStreamMapEntry(
      PostgresChangePayload payload) async {
    switch (payload.eventType) {
      case PostgresChangeEvent.update:
        RideData? rideStarted =
            allAvailableRides!.remove(payload.newRecord["driver_email"]);
        return MapEntry(DatabaseEventType.update, rideStarted!);
      case PostgresChangeEvent.delete:
        RideData? rideRemoved =
            allAvailableRides!.remove(payload.oldRecord["driver_email"]);
        return MapEntry(DatabaseEventType.delete, rideRemoved!);
      case PostgresChangeEvent.insert:
      case PostgresChangeEvent.all:
        RideData rideCreated =
            await _createRideDataByRawRecord(payload.newRecord);

        allAvailableRides![rideCreated.driver.email] = rideCreated;
        return MapEntry(DatabaseEventType.insert, rideCreated);
    }
  }
}
