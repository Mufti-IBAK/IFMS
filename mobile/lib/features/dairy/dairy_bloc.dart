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

class ChangeDashboardFilter extends DairyEvent {
  final AnalyticsFilter filter;
  ChangeDashboardFilter(this.filter);
}

class ChangeDashboardDate extends DairyEvent {
  final DateTime date;
  ChangeDashboardDate(this.date);
}

// --- States ---
abstract class DairyState {}

class DairyInitial extends DairyState {}
class DairyLoading extends DairyState {}

class DairyLoaded extends DairyState {
  final List<LocalMilkRecord> dashboardRecords;
  final double totalMilkDashboard;
  final double averagePerCowDashboard;
  final Map<String, double> topProducersDashboard;
  final Map<String, double> lowPerformersDashboard;
  
  final DateTime selectedDashboardDate;
  final AnalyticsFilter dashboardFilter;
  final Map<String, String> animalTagMap; // Maps UUID to Tag ID

  // Analytics tab specific
  final AnalyticsFilter currentFilter;
  final List<double> herdChartData;
  final List<String> herdChartLabels;
  final Map<String, double> cowYieldBreakdown;
  final Map<String, List<double>> cowChartData;
  final double totalYieldForPeriod;

  DairyLoaded({
    required this.dashboardRecords,
    required this.totalMilkDashboard,
    required this.averagePerCowDashboard,
    required this.topProducersDashboard,
    required this.lowPerformersDashboard,
    required this.selectedDashboardDate,
    required this.dashboardFilter,
    required this.animalTagMap,
    required this.currentFilter,
    required this.herdChartData,
    required this.herdChartLabels,
    required this.cowYieldBreakdown,
    required this.cowChartData,
    required this.totalYieldForPeriod,
  });

  DairyLoaded copyWith({
    List<LocalMilkRecord>? dashboardRecords,
    double? totalMilkDashboard,
    double? averagePerCowDashboard,
    Map<String, double>? topProducersDashboard,
    Map<String, double>? lowPerformersDashboard,
    DateTime? selectedDashboardDate,
    AnalyticsFilter? dashboardFilter,
    Map<String, String>? animalTagMap,
    AnalyticsFilter? currentFilter,
    List<double>? herdChartData,
    List<String>? herdChartLabels,
    Map<String, double>? cowYieldBreakdown,
    Map<String, List<double>>? cowChartData,
    double? totalYieldForPeriod,
  }) {
    return DairyLoaded(
      dashboardRecords: dashboardRecords ?? this.dashboardRecords,
      totalMilkDashboard: totalMilkDashboard ?? this.totalMilkDashboard,
      averagePerCowDashboard: averagePerCowDashboard ?? this.averagePerCowDashboard,
      topProducersDashboard: topProducersDashboard ?? this.topProducersDashboard,
      lowPerformersDashboard: lowPerformersDashboard ?? this.lowPerformersDashboard,
      selectedDashboardDate: selectedDashboardDate ?? this.selectedDashboardDate,
      dashboardFilter: dashboardFilter ?? this.dashboardFilter,
      animalTagMap: animalTagMap ?? this.animalTagMap,
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
  
  DateTime _dashboardDate = DateTime.now();
  AnalyticsFilter _dashboardFilter = AnalyticsFilter.daily;

  DairyBloc(this.dairyRepo, this.animalsRepo) : super(DairyInitial()) {
    on<LoadDairyData>(_onLoadDairyData);
    on<AddMilkEntry>(_onAddMilkEntry);
    on<ChangeAnalyticsFilter>(_onChangeAnalyticsFilter);
    on<ChangeDashboardFilter>(_onChangeDashboardFilter);
    on<ChangeDashboardDate>(_onChangeDashboardDate);
  }

  Future<void> _onLoadDairyData(LoadDairyData event, Emitter<DairyState> emit) async {
    emit(DairyLoading());
    await _loadAllData(emit);
  }
  
  Future<void> _onChangeDashboardFilter(ChangeDashboardFilter event, Emitter<DairyState> emit) async {
    _dashboardFilter = event.filter;
    if (state is DairyLoaded) {
      emit(DairyLoading());
      await _loadAllData(emit);
    }
  }

  Future<void> _onChangeDashboardDate(ChangeDashboardDate event, Emitter<DairyState> emit) async {
    _dashboardDate = event.date;
    if (state is DairyLoaded) {
      emit(DairyLoading());
      await _loadAllData(emit);
    }
  }

  Future<void> _loadAllData(Emitter<DairyState> emit) async {
    try {
      final animals = await animalsRepo.getAnimals();
      final tagMap = <String, String>{for (var a in animals) a.id: a.tagId};

      // 1. Dashboard Data based on _dashboardDate and _dashboardFilter
      DateTime dStart;
      DateTime dEnd;
      if (_dashboardFilter == AnalyticsFilter.daily) {
        dStart = DateTime(_dashboardDate.year, _dashboardDate.month, _dashboardDate.day);
        dEnd = DateTime(_dashboardDate.year, _dashboardDate.month, _dashboardDate.day, 23, 59, 59);
      } else if (_dashboardFilter == AnalyticsFilter.weekly) {
        // Week starts on Monday
        int weekday = _dashboardDate.weekday;
        dStart = DateTime(_dashboardDate.year, _dashboardDate.month, _dashboardDate.day - (weekday - 1));
        dEnd = dStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      } else {
        dStart = DateTime(_dashboardDate.year, _dashboardDate.month, 1);
        int nextMonth = _dashboardDate.month + 1;
        int year = _dashboardDate.year;
        if (nextMonth > 12) { nextMonth = 1; year++; }
        dEnd = DateTime(year, nextMonth, 1).subtract(const Duration(seconds: 1));
      }

      final dashboardRecords = await dairyRepo.getRecordsByDateRange(dStart, dEnd);
      double totalMilkDashboard = 0;
      final Map<String, double> cowTotals = {};

      for (var record in dashboardRecords) {
        if (!record.isWithdrawn) {
          totalMilkDashboard += record.quantityLiters;
          final key = tagMap[record.animalId] ?? record.animalId.substring(0, 8);
          cowTotals[key] = (cowTotals[key] ?? 0) + record.quantityLiters;
        }
      }

      final cowCount = cowTotals.keys.length;
      final averagePerCowDashboard = cowCount > 0 ? totalMilkDashboard / cowCount : 0.0;
      final sortedCows = cowTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final topProducersDashboard = Map.fromEntries(sortedCows.take(3));
      final lowPerformersDashboard = Map.fromEntries(sortedCows.reversed.take(3));

      // 2. Analytics Data
      final analyticsData = await _calculateAnalytics(_currentFilter, tagMap);

      emit(DairyLoaded(
        dashboardRecords: dashboardRecords,
        totalMilkDashboard: totalMilkDashboard,
        averagePerCowDashboard: averagePerCowDashboard,
        topProducersDashboard: topProducersDashboard,
        lowPerformersDashboard: lowPerformersDashboard,
        selectedDashboardDate: _dashboardDate,
        dashboardFilter: _dashboardFilter,
        animalTagMap: tagMap,
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
        final animals = await animalsRepo.getAnimals();
        final tagMap = <String, String>{for (var a in animals) a.id: a.tagId};
        final analyticsData = await _calculateAnalytics(_currentFilter, tagMap);
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

  Future<Map<String, dynamic>> _calculateAnalytics(AnalyticsFilter filter, Map<String, String> tagMap) async {
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
      final key = tagMap[r.animalId] ?? r.animalId.substring(0, 8);
      
      cowBreakdown[key] = (cowBreakdown[key] ?? 0) + r.quantityLiters;
      if (!cowChartData.containsKey(key)) {
        cowChartData[key] = List.filled(points, 0.0);
      }

      // Assign to chart bucket
      if (filter == AnalyticsFilter.daily) {
        final diff = r.recordDate.difference(start).inDays;
        if (diff >= 0 && diff < points) {
          chartData[diff] += r.quantityLiters;
          cowChartData[key]![diff] += r.quantityLiters;
        }
      } else if (filter == AnalyticsFilter.weekly) {
        final diff = r.recordDate.difference(start).inDays;
        int weekIndex = diff ~/ 7;
        if (weekIndex >= 0 && weekIndex < points) {
          chartData[weekIndex] += r.quantityLiters;
          cowChartData[key]![weekIndex] += r.quantityLiters;
        }
      } else if (filter == AnalyticsFilter.monthly) {
        // Calculate months difference
        int monthIndex = (r.recordDate.year - start.year) * 12 + r.recordDate.month - start.month;
        if (monthIndex >= 0 && monthIndex < points) {
          chartData[monthIndex] += r.quantityLiters;
          cowChartData[key]![monthIndex] += r.quantityLiters;
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
    }
  }
}
