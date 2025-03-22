import 'package:usper/constants/ride_data_event_type.dart';
import 'package:usper/constants/ride_requests_event_type.dart';
import 'package:usper/core/classes/class_ride_data.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';

abstract interface class RepositoryInterface {
  Future<bool> insertUser(UsperUser user);
  Future<void> insertVehicle(Vehicle vehicle, UsperUser user);
  Future<void> insertRide(String driverId, DateTime departTime, var originData,
      var destData, Vehicle vehicle);
  Future<List<Vehicle>> fetchVehiclesByOwner(String ownerId);
  Future<Map<String, RideData>> fetchAllAvaiableRides();
  Stream<MapEntry<RideDataEventType, RideData>> rideDataStream();
  Future<void> updateUser(final UsperUser user);
  Future<void> insertRideRequest(
      final RideData ride, final UsperUser passenger);
  Future<List<MapEntry<bool?, UsperUser>>> fetchAllRideRequests(
      String driverId);
  Stream<MapEntry<RideRequestsEventType, dynamic>> rideRequestsStream();
  void stopRideRequestsStream();
  Future<void> deleteRideRequest(String driverId, String passengerId);
}
