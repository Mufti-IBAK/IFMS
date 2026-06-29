import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/local_db.dart';
import 'poultry_repository.dart';

abstract class PoultryEvent {}
class LoadPoultryData extends PoultryEvent {}
class AddPoultryLog extends PoultryEvent {
  final String batchId;
  final Map<String, dynamic> data;
  AddPoultryLog(this.batchId, this.data);
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
      emit(PoultryLoading());
      try {
        final batches = await repository.getBatches();
        emit(PoultryLoaded(batches));
      } catch (e) {
        emit(PoultryError(e.toString()));
      }
    });

    on<AddPoultryLog>((event, emit) async {
      try {
        await repository.addDailyLog(event.batchId, event.data);
        add(LoadPoultryData());
      } catch (e) {
        emit(PoultryError(e.toString()));
      }
    });
  }
}
