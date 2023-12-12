import 'package:bloc/bloc.dart';

part 'ride_creation_event.dart';
part 'ride_creation_state.dart';

class RideCreationController
    extends Bloc<RideCreationEvent, RideCreationState> {
  RideCreationController() : super(SeatsCounterNewValue(0)) {
    on<SeatsCounterIncreased>(_increaseSeatsCounter);
    on<SeatsCounterDecreased>(_decreaseSeatsCounter);
  }

  int _seatsCounter = 0;
  final int _maxNumberOfSeats =
      4; //In the future, a better implementation shoud be proposed

  void _increaseSeatsCounter(
      SeatsCounterIncreased event, Emitter<RideCreationState> emit) {
    if (_seatsCounter == _maxNumberOfSeats) {
      emit(RideCreationStateError(
          "O número máximo de vagas desse veículo é ${_maxNumberOfSeats}"));
    } else {
      _seatsCounter++;
      emit(SeatsCounterNewValue(_seatsCounter));
    }
  }

  void _decreaseSeatsCounter(
      SeatsCounterDecreased event, Emitter<RideCreationState> emit) {
    if (_seatsCounter == 0) {
      emit(const RideCreationStateError(
          "Não é possível ter um valor negativo de assentos"));
    } else {
      _seatsCounter--;
      emit(SeatsCounterNewValue(_seatsCounter));
    }
  }
}
