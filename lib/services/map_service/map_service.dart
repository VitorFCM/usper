import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import 'package:usper/services/map_service/map_interface.dart';
import 'package:usper/utils/decode_polyline.dart';
import 'package:usper/utils/http_post.dart';

class MapService implements MapInterface {
  @override
  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    String? routesApiKey = dotenv.env['ROUTE_SERVICE_KEY'];
    if (routesApiKey == null) throw Exception();

    const String url =
        'https://api.openrouteservice.org/v2/directions/driving-car';

    final body = json.encode({
      "coordinates": [
        [origin.longitude, origin.latitude],
        [destination.longitude, destination.latitude]
      ]
    });

    final headers = {
      'Accept':
          'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
      'Authorization': routesApiKey,
      'Content-Type': 'application/json; charset=utf-8'
    };

    String? response = await httpPost(url, headers: headers, body: body);

    if (response == null) throw Exception();

    final jsonBody = json.decode(response);

    final String encodedGeometry = jsonBody['routes'][0]['geometry'];

    final List<LatLng> coordinates = decodePolyline(encodedGeometry);

    return coordinates;
  }
}
