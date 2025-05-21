import 'package:latlong2/latlong.dart';

abstract interface class MapInterface {
  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination);
}
