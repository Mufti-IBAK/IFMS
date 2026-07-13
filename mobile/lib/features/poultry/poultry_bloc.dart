import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/local_db.dart';
import 'poultry_repository.dart';

abstract class PoultryEvent {}

class LoadPoultryData extends PoultryEvent {}

class CreateBatch extends PoultryEvent {
  final Map<String, dynamic> data;
  CreateBatch(this.data);
}

class AddPoultryLog extends PoultryEvent {
  final String batchId;
  final Map<String, dynamic> data;
  AddPoultryLog(this.batchId, this.data);
}

class LogBatchEvent extends PoultryEvent {
  final String batchId;
  final Map<String, dynamic> data;
  LogBatchEvent(this.batchId, this.data);
}

class LogBatchSale extends PoultryEvent {
  final String batchId;
  final Map<String, dynamic> saleData;
  LogBatchSale(this.batchId, this.saleData);
}

abstract class PoultryState {}
class PoultryLoading extends PoultryState {}
class PoultryLoaded extends PoultryState {
  final List<LocalPoultryBatche> batches;
  PoultryLoaded(this.batches);
}
class PoultryError extends PoultryState {
  final String message;
  PoultryError(this.message);
}

class PoultryBloc extends Bloc<PoultryEvent, PoultryState> {
  final PoultryRepository repository;

  PoultryBloc(this.repository) : super(PoultryLoading()) {
    on<LoadPoultryData>((event, emit) async {
      final currentState = state;
      if (currentState is! PoultryLoaded) {
        emit(PoultryLoading());
      }
      try {
        final batches = await repository.getBatches();
        emit(PoultryLoaded(batches));
      } catch (e) {
        if (currentState is! PoultryLoaded) {
          emit(PoultryError(e.toString()));
        }
      }
    });

    on<CreateBatch>((event, emit) async {
      final currentState = state;
      try {
        await repository.createBatch(event.data);
        final batches = await repository.getBatches();
        emit(PoultryLoaded(batches));
      } catch (e) {
        emit(PoultryError(e.toString()));
      }
    });

    on<AddPoultryLog>((event, emit) async {
      try {
        await repository.addDailyLog(event.batchId, event.data);
        final batches = await repository.getBatches();
        emit(PoultryLoaded(batches));
      } catch (e) {
        emit(PoultryError(e.toString()));
      }
    });

    on<LogBatchEvent>((event, emit) async {
      try {
        await repository.logBatchEvent(event.batchId, event.data);
        final batches = await repository.getBatches();
        emit(PoultryLoaded(batches));
      } catch (e) {
        emit(PoultryError(e.toString()));
      }
    });

    on<LogBatchSale>((event, emit) async {
      try {
        await repository.logBatchSale(event.batchId, event.saleData);
        final batches = await repository.getBatches();
        emit(PoultryLoaded(batches));
      } catch (e) {
        emit(PoultryError(e.toString()));
      }
    });
  }
}
