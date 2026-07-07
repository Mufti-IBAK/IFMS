import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/local_db.dart';
import 'dairy_repository.dart';
import '../animals/animals_repository.dart';

// --- Events ---
abstract class DairyEvent {}

class LoadDairyData extends DairyEvent {}

class AddMilkEntry extends DairyEvent {
  final Map<String, dynamic> recordData;
  AddMilkEntry(this.recordData);
}

// --- States ---
abstract class DairyState {}

class DairyInitial extends DairyState {}
class DairyLoading extends DairyState {}

class DairyLoaded extends DairyState {
  final List<LocalMilkRecord> todayRecords;
  final double totalMilkToday;
  final double averagePerCow;
  final Map<String, double> topProducers; // animalId -> liters
  final Map<String, double> lowPerformers;

  DairyLoaded({
    required this.todayRecords,
    required this.totalMilkToday,
    required this.averagePerCow,
    required this.topProducers,
    required this.lowPerformers,
  });
}

class DairyError extends DairyState {
  final String message;
  DairyError(this.message);
}

// --- Bloc ---
class DairyBloc extends Bloc<DairyEvent, DairyState> {
  final DairyRepository dairyRepo;
  final AnimalsRepository animalsRepo;

  DairyBloc(this.dairyRepo, this.animalsRepo) : super(DairyInitial()) {
    on<LoadDairyData>(_onLoadDairyData);
    on<AddMilkEntry>(_onAddMilkEntry);
  }

  Future<void> _onLoadDairyData(LoadDairyData event, Emitter<DairyState> emit) async {
    emit(DairyLoading());
    try {
      final now = DateTime.now();
      final todayRecords = await dairyRepo.getHerdDailyTotal(now);
      
      double totalMilkToday = 0;
      final Map<String, double> cowTotals = {};

      for (var record in todayRecords) {
        if (!record.isWithdrawn) {
          totalMilkToday += record.quantityLiters;
          cowTotals[record.animalId] = (cowTotals[record.animalId] ?? 0) + record.quantityLiters;
        }
      }

      final cowCount = cowTotals.keys.length;
      final averagePerCow = cowCount > 0 ? totalMilkToday / cowCount : 0.0;

      // Sort cows by production
      final sortedCows = cowTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)); // descending

      final topProducers = Map.fromEntries(sortedCows.take(3));
      final lowPerformers = Map.fromEntries(sortedCows.reversed.take(3));

      emit(DairyLoaded(
        todayRecords: todayRecords,
        totalMilkToday: totalMilkToday,
        averagePerCow: averagePerCow,
        topProducers: topProducers,
        lowPerformers: lowPerformers,
      ));
    } catch (e) {
      emit(DairyError(e.toString()));
    }
  }

  Future<void> _onAddMilkEntry(AddMilkEntry event, Emitter<DairyState> emit) async {
    try {
      await dairyRepo.addMilkRecord(event.recordData);
      add(LoadDairyData()); // reload dashboard
    } catch (e) {
      emit(DairyError(e.toString()));
    }
  }
}
