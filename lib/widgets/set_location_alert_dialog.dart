import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:usper/constants/colors_constants.dart';

class SetLocationAlertDialog extends StatelessWidget {
  const SetLocationAlertDialog(
      {super.key, required this.onPickedFunction, required this.initPosition});

  final void Function(PickedData) onPickedFunction;
  final LatLong? initPosition;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FlutterLocationPicker(
              mapLanguage: 'pt',
              searchBarHintText: "Pesquisar localização",
              searchbarBorderRadius: BorderRadius.circular(20),
              searchbarInputBorder:
                  const OutlineInputBorder(borderSide: BorderSide.none),
              searchbarInputFocusBorderp:
                  const OutlineInputBorder(borderSide: BorderSide.none),
              initPosition: initPosition,
              selectLocationButtonStyle: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(yellow),
              ),
              selectedLocationButtonTextstyle: const TextStyle(fontSize: 18),
              selectLocationButtonText: 'Utilizar localização',
              selectLocationButtonLeadingIcon: const Icon(Icons.check),
              initZoom: 18,
              minZoomLevel: 5,
              maxZoomLevel: 20,
              onError: (e) => print(e),
              onPicked: onPickedFunction,
              markerIcon: const Icon(
                Icons.place,
                color: blue,
                size: 40,
              ),
            )));
  }
}
