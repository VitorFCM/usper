import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:usper/core/classes/class_vehicle.dart';

class RideData{
	String originName;
	String destName;
	LatLng originCoord;
	LatLng destCoord;
	DateTime departTime;
	late Vehicle vehicle;

	RideData(
		this.originName, 
		this.destName, 
		this.originCoord,
		this.destCoord, 
		this.departTime
	);
}
