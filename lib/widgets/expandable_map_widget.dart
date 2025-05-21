import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/constants/map_bounds.dart';

class ExpandableMapWidget extends StatelessWidget {
  final Map<String, Marker?> markersMap;
  final List<LatLng> routePoints;

  ExpandableMapWidget(
      {Key? key,
      LatLng? origin,
      LatLng? destination,
      this.routePoints = const []})
      : markersMap = {
          "origin": origin != null ? _buildMarker(origin) : null,
          "destination": destination != null ? _buildMarker(destination) : null,
        },
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: flutterMap(
            context,
            () => showDialog(
                context: context,
                builder: (context) => _dialog(flutterMap(
                      context,
                      () => Navigator.pop(context),
                      Icons.fullscreen_exit,
                    ))),
            Icons.fullscreen),
      ),
    );
  }

  Widget _dialog(Widget child) {
    return Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: child,
        ));
  }

  FlutterMap flutterMap(
      BuildContext context, void Function() onPressed, IconData icon) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(-23.550520, -46.633308),
        initialZoom: 13.0,
        cameraConstraint: CameraConstraint.contain(bounds: mapBounds),
        maxZoom: 16,
        minZoom: 3,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        ),
        MarkerLayer(
          markers:
              markersMap.values.where((v) => v != null).cast<Marker>().toList(),
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: routePoints,
              strokeWidth: 4.0,
              color: blue,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 10),
          child: Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: IconButton(
              icon: Icon(icon),
              onPressed: onPressed,
            ),
          ),
        ),
      ],
    );
  }

  static Marker _buildMarker(LatLng point) {
    return Marker(
      point: point,
      child: Icon(
        Icons.location_on,
        color: yellow,
        size: 40.0,
      ),
    );
  }
}
