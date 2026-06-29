import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/local_db.dart';
import 'dairy_repository.dart';

abstract class DairyEvent {}
class LoadDairyData extends DairyEvent {}
class AddMilkRecord extends DairyEvent {
  final Map<String, dynamic> data;
  AddMilkRecord(this.data);
}

abstract class DairyState {}
class DairyLoading extends DairyState {}
class DairyLoaded extends DairyState {
  final List<LocalMilkRecord> records;
  final double totalYield;
  final int activeCows;
  DairyLoaded(this.records, {this.totalYield = 0, this.activeCows = 0});
}
class DairyError extends DairyState {
  final String message;
  DairyError(this.message);
}

class DairyBloc extends Bloc<DairyEvent, DairyState> {
  final DairyRepository repository;

  DairyBloc(this.repository) : super(DairyLoading()) {
    on<LoadDairyData>((event, emit) async {
      emit(DairyLoading());
      try {
        final records = await repository.getMilkRecords();
        double total = 0;
        Set<String> uniqueCows = {};
        for (var r in records) {
          total += r.quantityLiters;
          uniqueCows.add(r.animalId);
        }
        emit(DairyLoaded(records, totalYield: total, activeCows: uniqueCows.length));
      } catch (e) {
        emit(DairyError(e.toString()));
      }
    });

    on<AddMilkRecord>((event, emit) async {
      try {
        await repository.addMilkRecord(event.data);
        add(LoadDairyData());
      } catch (e) {
        emit(DairyError(e.toString()));
      }
    });
  }
}
