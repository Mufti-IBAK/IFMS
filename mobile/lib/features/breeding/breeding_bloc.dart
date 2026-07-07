import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/local_db.dart';
import 'breeding_repository.dart';

// Events
abstract class BreedingEvent {}

class LoadBreedingHistory extends BreedingEvent {
  final String animalId;
  LoadBreedingHistory(this.animalId);
}

class LogNewBreedingEvent extends BreedingEvent {
  final String animalId;
  final String eventType;
  final DateTime eventDate;
  final String? sireId;
  final String? semenBatchId;
  final String? technician;
  final String? result;
  final String? notes;
  final String? payload;

  LogNewBreedingEvent({
    required this.animalId,
    required this.eventType,
    required this.eventDate,
    this.sireId,
    this.semenBatchId,
    this.technician,
    this.result,
    this.notes,
    this.payload,
  });
}

// States
abstract class BreedingState {}

class BreedingInitial extends BreedingState {}

class BreedingLoading extends BreedingState {}

class BreedingHistoryLoaded extends BreedingState {
  final List<LocalBreedingEvent> events;
  BreedingHistoryLoaded(this.events);
}

class BreedingActionSuccess extends BreedingState {}

class BreedingError extends BreedingState {
  final String message;
  BreedingError(this.message);
}

// Bloc
class BreedingBloc extends Bloc<BreedingEvent, BreedingState> {
  final BreedingRepository repository;

  BreedingBloc(this.repository) : super(BreedingInitial()) {
    on<LoadBreedingHistory>((event, emit) async {
      emit(BreedingLoading());
      try {
        final events = await repository.getBreedingEventsForAnimal(event.animalId);
        emit(BreedingHistoryLoaded(events));
      } catch (e) {
        emit(BreedingError(e.toString()));
      }
    });

    on<LogNewBreedingEvent>((event, emit) async {
      emit(BreedingLoading());
      try {
        await repository.logBreedingEvent(
          event.animalId,
          event.eventType,
          event.eventDate,
          sireId: event.sireId,
          semenBatchId: event.semenBatchId,
          technician: event.technician,
          result: event.result,
          notes: event.notes,
          payload: event.payload,
        );
        emit(BreedingActionSuccess());
        // Reload history
        final events = await repository.getBreedingEventsForAnimal(event.animalId);
        emit(BreedingHistoryLoaded(events));
      } catch (e) {
        emit(BreedingError(e.toString()));
      }
    });
  }
}
