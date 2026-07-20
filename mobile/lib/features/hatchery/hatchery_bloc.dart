import 'package:flutter_bloc/flutter_bloc.dart';
import 'hatchery_repository.dart';
import '../../core/di/service_locator.dart';
import '../../core/network/notification_service.dart';

abstract class HatcheryEvent {}

class LoadHatcheryBatches extends HatcheryEvent {}

class CreateHatcheryBatch extends HatcheryEvent {
  final Map<String, dynamic> batchData;
  CreateHatcheryBatch(this.batchData);
}

class AddHatcheryEvent extends HatcheryEvent {
  final String batchId;
  final Map<String, dynamic> eventData;
  AddHatcheryEvent(this.batchId, this.eventData);
}

abstract class HatcheryState {}

class HatcheryInitial extends HatcheryState {}

class HatcheryLoading extends HatcheryState {}

class HatcheryLoaded extends HatcheryState {
  final List<dynamic> batches;
  HatcheryLoaded(this.batches);
}

class HatcheryError extends HatcheryState {
  final String message;
  HatcheryError(this.message);
}

class HatcheryBloc extends Bloc<HatcheryEvent, HatcheryState> {
  final HatcheryRepository repository;

  HatcheryBloc(this.repository) : super(HatcheryInitial()) {
    on<LoadHatcheryBatches>((event, emit) async {
      final currentState = state;
      if (currentState is! HatcheryLoaded) {
        emit(HatcheryLoading());
      }
      try {
        final batches = await repository.getBatches();
        emit(HatcheryLoaded(batches));
      } catch (e) {
        if (currentState is! HatcheryLoaded) {
          emit(HatcheryError('Failed to load hatchery batches: ${e.toString()}'));
        }
      }
    });

    on<CreateHatcheryBatch>((event, emit) async {
      try {
        await repository.createBatch(event.batchData);
        sl<NotificationService>().showLocalNotification(
          'Hatchery Batch Started',
          'Batch #${event.batchData['batch_number']} successfully initialized.',
        );
        add(LoadHatcheryBatches());
      } catch (e) {
        if (e.toString().contains('Saved locally')) {
          sl<NotificationService>().showLocalNotification(
            'Hatchery Batch Started (Offline)',
            'Batch #${event.batchData['batch_number']} initialized locally. Will sync when online.',
          );
          add(LoadHatcheryBatches());
        } else {
          emit(HatcheryError('Failed to create hatchery batch: ${e.toString()}'));
        }
      }
    });

    on<AddHatcheryEvent>((event, emit) async {
      try {
        await repository.addEvent(event.batchId, event.eventData);
        add(LoadHatcheryBatches());
      } catch (e) {
        emit(HatcheryError('Failed to log hatchery event: ${e.toString()}'));
      }
    });
  }
}
