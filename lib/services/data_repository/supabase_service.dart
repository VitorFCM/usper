import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:usper/constants/ride_data_event_type.dart';
import 'package:usper/constants/datatbase_tables.dart';
import 'package:usper/constants/ride_requests_event_type.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';
import 'package:usper/services/data_repository/repository_interface.dart';
import 'package:usper/utils/database/delete_data.dart';
import 'package:usper/utils/database/fetch_data.dart';
import 'package:usper/utils/database/insert_data.dart';
import 'package:usper/utils/database/update_data.dart';

class SupabaseService implements RepositoryInterface {
  final StreamController<MapEntry<RideDataEventType, RideData>>
      _rideDataStreamController =
      StreamController<MapEntry<RideDataEventType, RideData>>.broadcast();

  StreamController<MapEntry<RideRequestsEventType, dynamic>>
      _rideRequestsStreamController =
      StreamController<MapEntry<RideRequestsEventType, dynamic>>.broadcast();

  late RealtimeChannel supabaseRideRequestsChannel;

  final supabase = Supabase.instance.client;

  Map<String, RideData>? allAvailableRides;

  SupabaseService() {
    _init();
  }

  @override
  Future<bool> insertUser(UsperUser user) async {
    try {
      await insertData(DatabaseTables.users, {
        "email": user.email,
        "image_link": user.imageLink,
        "first_name": user.firstName,
        "last_name": user.lastName
      });
      return true;
    } on PostgrestException catch (e) {
      if (e.code != null && "23505".compareTo(e.code!) == 0) {
        return false;
      }
      rethrow;
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
  Stream<MapEntry<RideDataEventType, RideData>> rideDataStream() {
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

  Future<UsperUser> _fetchUser(final String userEmail) async {
    List<Map<String, dynamic>> rawList =
        await fetchData(DatabaseTables.users, {"email": userEmail});

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

    UsperUser driver = await _fetchUser(record["driver_email"]);

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
              _rideDataStreamController
                  .add(await _payloadToStreamRideData(payload));
            })
        .subscribe();
  }

  Future<MapEntry<RideDataEventType, RideData>> _payloadToStreamRideData(
      PostgresChangePayload payload) async {
    switch (payload.eventType) {
      case PostgresChangeEvent.update:
        RideData? rideStarted =
            allAvailableRides!.remove(payload.newRecord["driver_email"]);
        return MapEntry(RideDataEventType.update, rideStarted!);
      case PostgresChangeEvent.delete:
        RideData? rideRemoved =
            allAvailableRides!.remove(payload.oldRecord["driver_email"]);
        return MapEntry(RideDataEventType.delete, rideRemoved!);
      case PostgresChangeEvent.insert:
      case PostgresChangeEvent.all:
        RideData rideCreated =
            await _createRideDataByRawRecord(payload.newRecord);

        allAvailableRides![rideCreated.driver.email] = rideCreated;
        return MapEntry(RideDataEventType.insert, rideCreated);
    }
  }

  @override
  Future<void> updateUser(final UsperUser user) async {
    await updateData(
        DatabaseTables.users,
        {
          "image_link": user.imageLink,
          "first_name": user.firstName,
          "last_name": user.lastName,
          "course": user.course
        },
        MapEntry("email", user.email));
  }

  @override
  Future<void> insertRideRequest(RideData ride, UsperUser passenger) async {
    try {
      await insertData(DatabaseTables.ride_requests, {
        "driver_email": ride.driver.email,
        "passenger_email": passenger.email
      });
      _initRideRequestsController(ride.driver.email);
    } catch (e) {
      print(e);
    }
  }

  void _initRideRequestsController(String driverId) {
    if (_rideRequestsStreamController.isClosed) {
      _rideRequestsStreamController = StreamController<
          MapEntry<RideRequestsEventType, dynamic>>.broadcast();
    }
    supabaseRideRequestsChannel = supabase
        .channel("public:${DatabaseTables.ride_requests.name}")
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: DatabaseTables.ride_requests.name,
            filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'driver_email',
                value: driverId),
            callback: (payload) async {
              print(payload);
              _rideRequestsStreamController
                  .add(await _payloadToStreamRideRequest(payload));
            })
        .subscribe();
  }

  Future<MapEntry<RideRequestsEventType, dynamic>> _payloadToStreamRideRequest(
      PostgresChangePayload payload) async {
    switch (payload.eventType) {
      case PostgresChangeEvent.update:
        if (payload.newRecord["accepted"]) {
          return MapEntry(RideRequestsEventType.accepted,
              await _fetchUser(payload.newRecord["passenger_email"]));
        } else {
          return MapEntry(RideRequestsEventType.refused,
              payload.newRecord["passenger_email"]);
        }

      case PostgresChangeEvent.delete:
        return MapEntry(RideRequestsEventType.cancelled,
            payload.oldRecord["passenger_email"]);
      case PostgresChangeEvent.insert:
      case PostgresChangeEvent.all:
        return MapEntry(RideRequestsEventType.requested,
            await _fetchUser(payload.newRecord["passenger_email"]));
    }
  }

  @override
  Future<List<MapEntry<bool?, UsperUser>>> fetchAllRideRequests(
      String driverId) async {
    List<Map<String, dynamic>> rawList = await fetchData(
        DatabaseTables.ride_requests, {"driver_email": driverId});

    return [
      for (var record in rawList)
        MapEntry(
            record["accepted"], await _fetchUser(record["passenger_email"]))
    ];
  }

  @override
  Stream<MapEntry<RideRequestsEventType, dynamic>> rideRequestsStream() {
    return _rideRequestsStreamController.stream;
  }

  @override
  void stopRideRequestsStream() {
    _rideRequestsStreamController.close();
    supabaseRideRequestsChannel.unsubscribe();
  }

  @override
  Future<void> deleteRideRequest(String driverId, String passengerId) async {
    await deleteData(DatabaseTables.ride_requests,
        {"driver_email": driverId, "passenger_email": passengerId});
  }
}
