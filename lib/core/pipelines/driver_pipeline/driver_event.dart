part of 'driver_bloc.dart';

sealed class DriverEvent {}

final class CreateRide extends DriverEvent{}

final class StartRide extends DriverEvent{}

final class FinishRide extends DriverEvent{}

final class CancelRide extends DriverEvent{}
