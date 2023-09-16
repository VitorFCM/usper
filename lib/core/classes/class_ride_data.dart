import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:usper/core/classes/class_vehicle.dart';

class RideData {
  String originName;
  String destName;
  LatLng originCoord;
  LatLng destCoord;
  DateTime departTime;
  Vehicle vehicle;

  RideData(
      {required this.originName,
      required this.destName,
      required this.originCoord,
      required this.destCoord,
      required this.departTime,
      required this.vehicle});
}
