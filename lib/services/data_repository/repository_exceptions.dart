class PassengerAlreadyRequestedARideException implements Exception {
  PassengerAlreadyRequestedARideException({required this.rideId});
  String rideId;
}
