import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';

abstract interface class RepositoryInterface {
  Future<void> insertUser(UsperUser user);
  Future<void> insertVehicle(Vehicle vehicle, UsperUser user);
  Future<void> insertRide(String driverId, DateTime departTime, var originData,
      var destData, Vehicle vehicle);
  Future<List<Vehicle>> fetchVehiclesByOwner(String ownerId);
}
