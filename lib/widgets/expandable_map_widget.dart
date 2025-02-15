import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/modules/ride_creation/ride_creation_controller/ride_creation_controller.dart';

class ExpandableMapWidget extends StatelessWidget {
  ExpandableMapWidget();

  Map<String, Marker?> markersMap = {"origin": null, "destination": null};

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 200, // Ajusta a altura com base no estado
        child: flutterMap(
            context,
            () => showDialog(
                context: context,
                builder: (context) => _dialog(flutterMap(
                    context,
                    () => Navigator.pop(context),
                    Icons.fullscreen_exit,
                    MarkerLayer(
                      markers: markersMap.values
                          .where((v) => v != null)
                          .cast<Marker>()
                          .toList(),
                    )))),
            Icons.fullscreen,
            _buildBlocBuilder(context)),
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

  FlutterMap flutterMap(BuildContext context, void Function() onPressed,
      IconData icon, Widget markers) {
    return FlutterMap(
      options: MapOptions(
        initialCenter:
            LatLng(-23.550520, -46.633308), // Coordenadas de São Paulo, Brasil
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        ),
        markers,
        PolylineLayer(
          polylines: [
            Polyline(
              points: [
                LatLng(37.7749, -122.4194), // San Francisco
                LatLng(34.0522, -118.2437), // Los Angeles
                LatLng(36.1699, -115.1398), // Las Vegas
              ],
              strokeWidth: 4.0,
              color: Colors.blue,
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

  Marker _buildMarker(LatLng point) {
    return Marker(
      point: point,
      child: Container(
        child: const Icon(
          Icons.location_on,
          color: blue,
          size: 40.0,
        ),
      ),
    );
  }

  BlocBuilder _buildBlocBuilder(BuildContext context) {
    return BlocBuilder<RideCreationController, RideCreationState>(
      buildWhen: (previous, current) {
        return current is LocationSetted;
      },
      builder: (context, state) {
        if (state is OriginLocationSetted) {
          markersMap["origin"] = _buildMarker(state.location);
        } else if (state is DestLocationSetted) {
          markersMap["destination"] = _buildMarker(state.location);
        }

        return MarkerLayer(
          markers:
              markersMap.values.where((v) => v != null).cast<Marker>().toList(),
        );
      },
    );
  }
}
