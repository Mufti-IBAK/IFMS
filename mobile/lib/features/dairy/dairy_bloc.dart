import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/local_db.dart';
import 'dairy_repository.dart';
import '../animals/animals_repository.dart';

enum AnalyticsFilter { daily, weekly, monthly }

// --- Events ---
abstract class DairyEvent {}

class LoadDairyData extends DairyEvent {}

class AddMilkEntry extends DairyEvent {
  final Map<String, dynamic> recordData;
  AddMilkEntry(this.recordData);
}

class ChangeAnalyticsFilter extends DairyEvent {
  final AnalyticsFilter filter;
  ChangeAnalyticsFilter(this.filter);
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

  // Analytics tab specific
  final AnalyticsFilter currentFilter;
  final List<double> herdChartData;
  final List<String> herdChartLabels;
  final Map<String, double> cowYieldBreakdown;
  final Map<String, List<double>> cowChartData;
  final double totalYieldForPeriod;

  DairyLoaded({
    required this.todayRecords,
    required this.totalMilkToday,
    required this.averagePerCow,
    required this.topProducers,
    required this.lowPerformers,
    required this.currentFilter,
    required this.herdChartData,
    required this.herdChartLabels,
    required this.cowYieldBreakdown,
    required this.cowChartData,
    required this.totalYieldForPeriod,
  });

  DairyLoaded copyWith({
    List<LocalMilkRecord>? todayRecords,
    double? totalMilkToday,
    double? averagePerCow,
    Map<String, double>? topProducers,
    Map<String, double>? lowPerformers,
    AnalyticsFilter? currentFilter,
    List<double>? herdChartData,
    List<String>? herdChartLabels,
    Map<String, double>? cowYieldBreakdown,
    Map<String, List<double>>? cowChartData,
    double? totalYieldForPeriod,
  }) {
    return DairyLoaded(
      todayRecords: todayRecords ?? this.todayRecords,
      totalMilkToday: totalMilkToday ?? this.totalMilkToday,
      averagePerCow: averagePerCow ?? this.averagePerCow,
      topProducers: topProducers ?? this.topProducers,
      lowPerformers: lowPerformers ?? this.lowPerformers,
      currentFilter: currentFilter ?? this.currentFilter,
      herdChartData: herdChartData ?? this.herdChartData,
      herdChartLabels: herdChartLabels ?? this.herdChartLabels,
      cowYieldBreakdown: cowYieldBreakdown ?? this.cowYieldBreakdown,
      cowChartData: cowChartData ?? this.cowChartData,
      totalYieldForPeriod: totalYieldForPeriod ?? this.totalYieldForPeriod,
    );
  }
}

class DairyError extends DairyState {
  final String message;
  DairyError(this.message);
}

// --- Bloc ---
class DairyBloc extends Bloc<DairyEvent, DairyState> {
  final DairyRepository dairyRepo;
  final AnimalsRepository animalsRepo;
  AnalyticsFilter _currentFilter = AnalyticsFilter.daily;

  DairyBloc(this.dairyRepo, this.animalsRepo) : super(DairyInitial()) {
    on<LoadDairyData>(_onLoadDairyData);
    on<AddMilkEntry>(_onAddMilkEntry);
    on<ChangeAnalyticsFilter>(_onChangeAnalyticsFilter);
  }

  Future<void> _onLoadDairyData(LoadDairyData event, Emitter<DairyState> emit) async {
    emit(DairyLoading());
    try {
      final now = DateTime.now();
      
      // Dashboard Data
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
      final sortedCows = cowTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final topProducers = Map.fromEntries(sortedCows.take(3));
      final lowPerformers = Map.fromEntries(sortedCows.reversed.take(3));

      // Analytics Data
      final analyticsData = await _calculateAnalytics(_currentFilter);

      emit(DairyLoaded(
        todayRecords: todayRecords,
        totalMilkToday: totalMilkToday,
        averagePerCow: averagePerCow,
        topProducers: topProducers,
        lowPerformers: lowPerformers,
        currentFilter: _currentFilter,
        herdChartData: analyticsData['chartData'] as List<double>,
        herdChartLabels: analyticsData['chartLabels'] as List<String>,
        cowYieldBreakdown: analyticsData['cowBreakdown'] as Map<String, double>,
        cowChartData: analyticsData['cowChartData'] as Map<String, List<double>>,
        totalYieldForPeriod: analyticsData['totalYield'] as double,
      ));
    } catch (e) {
      emit(DairyError(e.toString()));
    }
  }

  Future<void> _onChangeAnalyticsFilter(ChangeAnalyticsFilter event, Emitter<DairyState> emit) async {
    if (state is DairyLoaded) {
      final currentState = state as DairyLoaded;
      _currentFilter = event.filter;
      try {
        final analyticsData = await _calculateAnalytics(_currentFilter);
        emit(currentState.copyWith(
          currentFilter: _currentFilter,
          herdChartData: analyticsData['chartData'] as List<double>,
          herdChartLabels: analyticsData['chartLabels'] as List<String>,
          cowYieldBreakdown: analyticsData['cowBreakdown'] as Map<String, double>,
          cowChartData: analyticsData['cowChartData'] as Map<String, List<double>>,
          totalYieldForPeriod: analyticsData['totalYield'] as double,
        ));
      } catch (e) {
        emit(DairyError(e.toString()));
      }
    }
  }

  Future<Map<String, dynamic>> _calculateAnalytics(AnalyticsFilter filter) async {
    final now = DateTime.now();
    DateTime start;
    int points;
    List<String> labels = [];
    
    if (filter == AnalyticsFilter.daily) {
      start = now.subtract(const Duration(days: 6));
      start = DateTime(start.year, start.month, start.day); // 7 days total (today + 6 past)
      points = 7;
    } else if (filter == AnalyticsFilter.weekly) {
      start = now.subtract(const Duration(days: 27)); // 4 weeks total
      start = DateTime(start.year, start.month, start.day);
      points = 4;
    } else {
      start = DateTime(now.year, now.month - 11, 1); // 12 months total
      points = 12;
    }

    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final records = await dairyRepo.getRecordsByDateRange(start, end);

    final Map<String, double> cowBreakdown = {};
    final Map<String, List<double>> cowChartData = {};
    double totalYield = 0.0;
    List<double> chartData = List.filled(points, 0.0);

    for (var r in records) {
      if (r.isWithdrawn) continue;
      
      totalYield += r.quantityLiters;
      cowBreakdown[r.animalId] = (cowBreakdown[r.animalId] ?? 0) + r.quantityLiters;
      if (!cowChartData.containsKey(r.animalId)) {
        cowChartData[r.animalId] = List.filled(points, 0.0);
      }

      // Assign to chart bucket
      if (filter == AnalyticsFilter.daily) {
        final diff = r.recordDate.difference(start).inDays;
        if (diff >= 0 && diff < points) {
          chartData[diff] += r.quantityLiters;
          cowChartData[r.animalId]![diff] += r.quantityLiters;
        }
      } else if (filter == AnalyticsFilter.weekly) {
        final diff = r.recordDate.difference(start).inDays;
        int weekIndex = diff ~/ 7;
        if (weekIndex >= 0 && weekIndex < points) {
          chartData[weekIndex] += r.quantityLiters;
          cowChartData[r.animalId]![weekIndex] += r.quantityLiters;
        }
      } else if (filter == AnalyticsFilter.monthly) {
        // Calculate months difference
        int monthIndex = (r.recordDate.year - start.year) * 12 + r.recordDate.month - start.month;
        if (monthIndex >= 0 && monthIndex < points) {
          chartData[monthIndex] += r.quantityLiters;
          cowChartData[r.animalId]![monthIndex] += r.quantityLiters;
        }
      }
    }

    // Generate labels
    if (filter == AnalyticsFilter.daily) {
      for (int i = 0; i < points; i++) {
        final d = start.add(Duration(days: i));
        labels.add('${d.day}/${d.month}');
      }
    } else if (filter == AnalyticsFilter.weekly) {
      for (int i = 0; i < points; i++) {
        labels.add('W${i+1}');
      }
    } else if (filter == AnalyticsFilter.monthly) {
      final monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      for (int i = 0; i < points; i++) {
        int m = (start.month + i - 1) % 12;
        labels.add(monthNames[m]);
      }
    }

    // Sort cow breakdown
    final sortedBreakdown = cowBreakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final sortedMap = Map.fromEntries(sortedBreakdown);

    return {
      'chartData': chartData,
      'chartLabels': labels,
      'cowBreakdown': sortedMap,
      'cowChartData': cowChartData,
      'totalYield': totalYield,
    };
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
