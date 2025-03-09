import 'package:usper/constants/database_event_type.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';

abstract interface class RepositoryInterface {
  Future<void> insertUser(UsperUser user);
  Future<void> insertVehicle(Vehicle vehicle, UsperUser user);
  Future<void> insertRide(String driverId, DateTime departTime, var originData,
      var destData, Vehicle vehicle);
  Future<List<Vehicle>> fetchVehiclesByOwner(String ownerId);
  Future<Map<String, RideData>> fetchAllAvaiableRides();
  Stream<MapEntry<DatabaseEventType, RideData>> rideDataStream();
}
