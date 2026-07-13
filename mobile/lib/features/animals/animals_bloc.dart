import 'package:flutter_bloc/flutter_bloc.dart';
import 'animals_repository.dart';
import '../../core/di/service_locator.dart';
import '../../core/network/notification_service.dart';

// EVENTS
abstract class AnimalsEvent {}
class LoadAnimals extends AnimalsEvent {}
class AddAnimal extends AnimalsEvent {
  final Map<String, dynamic> animalData;
  AddAnimal(this.animalData);
}
class AddAnimalEvent extends AnimalsEvent {
  final String animalId;
  final String eventType;
  final Map<String, dynamic> payload;
  AddAnimalEvent(this.animalId, this.eventType, this.payload);
}
class UpdateAnimal extends AnimalsEvent {
  final String id;
  final Map<String, dynamic> updateData;
  UpdateAnimal(this.id, this.updateData);
}
class DeleteAnimal extends AnimalsEvent {
  final String id;
  DeleteAnimal(this.id);
}

// STATES
abstract class AnimalsState {}
class AnimalsLoading extends AnimalsState {}
class AnimalsLoaded extends AnimalsState {
  final List<dynamic> animals;
  final bool isOffline;
  AnimalsLoaded(this.animals, {this.isOffline = false});
}
class AnimalsError extends AnimalsState {
  final String message;
  AnimalsError(this.message);
}

// BLOC
class AnimalsBloc extends Bloc<AnimalsEvent, AnimalsState> {
  final AnimalsRepository repository;

  AnimalsBloc(this.repository) : super(AnimalsLoading()) {
    on<LoadAnimals>((event, emit) async {
      final currentState = state;
      if (currentState is! AnimalsLoaded) {
        emit(AnimalsLoading());
      }
      try {
        final animals = await repository.getAnimals();
        emit(AnimalsLoaded(animals));
      } catch (e) {
        if (currentState is! AnimalsLoaded) {
          emit(AnimalsError('Failed to load animals: ${e.toString()}'));
        }
      }
    });

    on<AddAnimal>((event, emit) async {
      try {
        await repository.addAnimal(event.animalData);
        sl<NotificationService>().showLocalNotification(
          'Animal Registered',
          'Animal #${event.animalData['tag_id']} successfully registered.',
        );
        add(LoadAnimals());
      } catch (e) {
        emit(AnimalsError('Failed to add animal: ${e.toString()}'));
      }
    });

    on<AddAnimalEvent>((event, emit) async {
      try {
        await repository.logAnimalEvent(event.animalId, event.eventType, event.payload);
        add(LoadAnimals());
      } catch (e) {
        emit(AnimalsError('Failed to log event: ${e.toString()}'));
      }
    });

    on<UpdateAnimal>((event, emit) async {
      try {
        await repository.updateAnimal(event.id, event.updateData);
        add(LoadAnimals());
      } catch (e) {
        emit(AnimalsError('Failed to update animal: ${e.toString()}'));
      }
    });

    on<DeleteAnimal>((event, emit) async {
      try {
        await repository.deleteAnimal(event.id);
        add(LoadAnimals());
      } catch (e) {
        emit(AnimalsError('Failed to delete animal: ${e.toString()}'));
      }
    });
  }
}
