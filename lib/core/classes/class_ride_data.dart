import 'package:latlong2/latlong.dart';
import 'package:usper/core/classes/class_usper_user.dart';
import 'package:usper/core/classes/class_vehicle.dart';

class RideData {
  String originName;
  String destName;
  LatLng originCoord;
  LatLng destCoord;
  DateTime departTime;
  Vehicle vehicle;
  UsperUser driver;

  RideData(
      {required this.originName,
      required this.destName,
      required this.originCoord,
      required this.destCoord,
      required this.departTime,
      required this.vehicle,
      required this.driver});
}
