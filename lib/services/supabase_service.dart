import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:usper/constants/datatbase_tables.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';
import 'package:usper/services/interfaces/repository_interface.dart';
import 'package:usper/utils/database/fetch_data.dart';
import 'package:usper/utils/database/insert_data.dart';

class SupabaseService implements RepositoryInterface {
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
    List<Map<String, dynamic>> rawList =
        await fetchData(DatabaseTables.vehicles, {"owner_email": ownerId});

    return rawList
        .map((value) => Vehicle(
            value["seats"], value["model"], value["plate"], value["color"]))
        .toList();
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
}
