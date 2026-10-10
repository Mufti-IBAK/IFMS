import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/local_db.dart';
import '../../core/sync/sync_event_bus.dart';
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

class UpdateMilkEntry extends DairyEvent {
  final String id;
  final Map<String, dynamic> recordData;
  UpdateMilkEntry(this.id, this.recordData);
}

class DeleteMilkEntry extends DairyEvent {
  final String id;
  DeleteMilkEntry(this.id);
}

class RecordMilkSaleEvent extends DairyEvent {
  final double quantityLiters;
  final double pricePerLiter;
  final String buyerName;
  final String? notes;

  RecordMilkSaleEvent({
    required this.quantityLiters,
    required this.pricePerLiter,
    required this.buyerName,
    this.notes,
  });
}

class EditMilkSaleEvent extends DairyEvent {
  final String id;
  final double quantityLiters;
  final double pricePerLiter;
  final String buyerName;
  final String? notes;

  EditMilkSaleEvent({
    required this.id,
    required this.quantityLiters,
    required this.pricePerLiter,
    required this.buyerName,
    this.notes,
  });
}

class DeleteMilkSaleEvent extends DairyEvent {
  final String id;
  DeleteMilkSaleEvent(this.id);
}

class UpdateMilkPriceEvent extends DairyEvent {
  final double newPrice;
  UpdateMilkPriceEvent(this.newPrice);
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
  final int cowsMilkedCount;
  final double monthlyMilkTotal;
  final double allTimeMilkTotal;
  
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

  // Store & Sales tab specific
  final double currentMilkPrice;
  final double totalCollectedLiters;
  final double totalWithdrawnLiters;
  final double totalSoldLiters;
  final double totalRevenue;
  final double inStoreLiters;
  final double inStoreValue;
  final List<LocalTransaction> salesHistory;

  DairyLoaded({
    required this.dashboardRecords,
    required this.totalMilkDashboard,
    required this.averagePerCowDashboard,
    required this.topProducersDashboard,
    required this.lowPerformersDashboard,
    required this.cowsMilkedCount,
    required this.monthlyMilkTotal,
    required this.allTimeMilkTotal,
    required this.selectedDashboardDate,
    required this.dashboardFilter,
    required this.animalTagMap,
    required this.currentFilter,
    required this.herdChartData,
    required this.herdChartLabels,
    required this.cowYieldBreakdown,
    required this.cowChartData,
    required this.totalYieldForPeriod,
    this.currentMilkPrice = 500.0,
    this.totalCollectedLiters = 0.0,
    this.totalWithdrawnLiters = 0.0,
    this.totalSoldLiters = 0.0,
    this.totalRevenue = 0.0,
    this.inStoreLiters = 0.0,
    this.inStoreValue = 0.0,
    this.salesHistory = const [],
  });

  DairyLoaded copyWith({
    List<LocalMilkRecord>? dashboardRecords,
    double? totalMilkDashboard,
    double? averagePerCowDashboard,
    Map<String, double>? topProducersDashboard,
    Map<String, double>? lowPerformersDashboard,
    int? cowsMilkedCount,
    double? monthlyMilkTotal,
    double? allTimeMilkTotal,
    DateTime? selectedDashboardDate,
    AnalyticsFilter? dashboardFilter,
    Map<String, String>? animalTagMap,
    AnalyticsFilter? currentFilter,
    List<double>? herdChartData,
    List<String>? herdChartLabels,
    Map<String, double>? cowYieldBreakdown,
    Map<String, List<double>>? cowChartData,
    double? totalYieldForPeriod,
    double? currentMilkPrice,
    double? totalCollectedLiters,
    double? totalWithdrawnLiters,
    double? totalSoldLiters,
    double? totalRevenue,
    double? inStoreLiters,
    double? inStoreValue,
    List<LocalTransaction>? salesHistory,
  }) {
    return DairyLoaded(
      dashboardRecords: dashboardRecords ?? this.dashboardRecords,
      totalMilkDashboard: totalMilkDashboard ?? this.totalMilkDashboard,
      averagePerCowDashboard: averagePerCowDashboard ?? this.averagePerCowDashboard,
      topProducersDashboard: topProducersDashboard ?? this.topProducersDashboard,
      lowPerformersDashboard: lowPerformersDashboard ?? this.lowPerformersDashboard,
      cowsMilkedCount: cowsMilkedCount ?? this.cowsMilkedCount,
      monthlyMilkTotal: monthlyMilkTotal ?? this.monthlyMilkTotal,
      allTimeMilkTotal: allTimeMilkTotal ?? this.allTimeMilkTotal,
      selectedDashboardDate: selectedDashboardDate ?? this.selectedDashboardDate,
      dashboardFilter: dashboardFilter ?? this.dashboardFilter,
      animalTagMap: animalTagMap ?? this.animalTagMap,
      currentFilter: currentFilter ?? this.currentFilter,
      herdChartData: herdChartData ?? this.herdChartData,
      herdChartLabels: herdChartLabels ?? this.herdChartLabels,
      cowYieldBreakdown: cowYieldBreakdown ?? this.cowYieldBreakdown,
      cowChartData: cowChartData ?? this.cowChartData,
      totalYieldForPeriod: totalYieldForPeriod ?? this.totalYieldForPeriod,
      currentMilkPrice: currentMilkPrice ?? this.currentMilkPrice,
      totalCollectedLiters: totalCollectedLiters ?? this.totalCollectedLiters,
      totalWithdrawnLiters: totalWithdrawnLiters ?? this.totalWithdrawnLiters,
      totalSoldLiters: totalSoldLiters ?? this.totalSoldLiters,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      inStoreLiters: inStoreLiters ?? this.inStoreLiters,
      inStoreValue: inStoreValue ?? this.inStoreValue,
      salesHistory: salesHistory ?? this.salesHistory,
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

  StreamSubscription<SyncCompletedEvent>? _syncSubscription;

  DairyBloc(this.dairyRepo, this.animalsRepo) : super(DairyInitial()) {
    on<LoadDairyData>(_onLoadDairyData);
    on<AddMilkEntry>(_onAddMilkEntry);
    on<ChangeAnalyticsFilter>(_onChangeAnalyticsFilter);
    on<ChangeDashboardFilter>(_onChangeDashboardFilter);
    on<ChangeDashboardDate>(_onChangeDashboardDate);
    on<UpdateMilkEntry>(_onUpdateMilkEntry);
    on<DeleteMilkEntry>(_onDeleteMilkEntry);
    on<RecordMilkSaleEvent>(_onRecordMilkSale);
    on<EditMilkSaleEvent>(_onEditMilkSale);
    on<DeleteMilkSaleEvent>(_onDeleteMilkSale);
    on<UpdateMilkPriceEvent>(_onUpdateMilkPrice);

    _syncSubscription = SyncEventBus().stream.listen((event) {
      if (event.containsAny(['milk_records', 'animals', 'transactions', 'milk_price'])) {
        add(LoadDairyData());
      }
    });
  }

  @override
  Future<void> close() {
    _syncSubscription?.cancel();
    return super.close();
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

  Future<void> _onUpdateMilkPrice(UpdateMilkPriceEvent event, Emitter<DairyState> emit) async {
    try {
      await dairyRepo.updateMilkPrice(event.newPrice);
      add(LoadDairyData());
    } catch (e) {
      emit(DairyError(e.toString().replaceAll('Exception:', '').trim()));
    }
  }

  Future<void> _onRecordMilkSale(RecordMilkSaleEvent event, Emitter<DairyState> emit) async {
    try {
      await dairyRepo.recordBulkMilkSale(
        quantityLiters: event.quantityLiters,
        pricePerLiter: event.pricePerLiter,
        buyerName: event.buyerName,
        notes: event.notes,
      );
      add(LoadDairyData());
    } catch (e) {
      emit(DairyError(e.toString().replaceAll('Exception:', '').trim()));
    }
  }

  Future<void> _onEditMilkSale(EditMilkSaleEvent event, Emitter<DairyState> emit) async {
    try {
      await dairyRepo.editMilkSaleTransaction(
        event.id,
        quantityLiters: event.quantityLiters,
        pricePerLiter: event.pricePerLiter,
        buyerName: event.buyerName,
        notes: event.notes,
      );
      add(LoadDairyData());
    } catch (e) {
      emit(DairyError(e.toString().replaceAll('Exception:', '').trim()));
    }
  }

  Future<void> _onDeleteMilkSale(DeleteMilkSaleEvent event, Emitter<DairyState> emit) async {
    try {
      await dairyRepo.deleteMilkSaleTransaction(event.id);
      add(LoadDairyData());
    } catch (e) {
      emit(DairyError(e.toString().replaceAll('Exception:', '').trim()));
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
        dEnd = dStart.add(const Duration(days: 1));
      } else if (_dashboardFilter == AnalyticsFilter.weekly) {
        int weekday = _dashboardDate.weekday;
        dStart = DateTime(_dashboardDate.year, _dashboardDate.month, _dashboardDate.day - (weekday - 1));
        dEnd = dStart.add(const Duration(days: 7));
      } else {
        dStart = DateTime(_dashboardDate.year, _dashboardDate.month, 1);
        dEnd = DateTime(_dashboardDate.year, _dashboardDate.month + 1, 1);
      }

      final dashboardRecords = await dairyRepo.getRecordsByDateRange(dStart, dEnd);

      double totalMilkDashboard = 0.0;
      final Map<String, double> cowTotalsDashboard = {};

      for (var r in dashboardRecords) {
        if (!r.isWithdrawn) {
          totalMilkDashboard += r.quantityLiters;
          final tag = tagMap[r.animalId] ?? r.animalId.substring(0, 8);
          cowTotalsDashboard[tag] = (cowTotalsDashboard[tag] ?? 0.0) + r.quantityLiters;
        }
      }

      final cowsMilkedCount = cowTotalsDashboard.length;
      final averagePerCowDashboard = cowsMilkedCount > 0 ? (totalMilkDashboard / cowsMilkedCount) : 0.0;

      final sortedCowsDashboard = cowTotalsDashboard.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final Map<String, double> topProducersDashboard = Map.fromEntries(sortedCowsDashboard.take(3));
      final Map<String, double> lowPerformersDashboard = Map.fromEntries(sortedCowsDashboard.reversed.take(3));

      // 2. Monthly Milk Total
      final now = DateTime.now();
      final mStart = DateTime(now.year, now.month, 1);
      final mEnd = DateTime(now.year, now.month + 1, 1);
      final monthlyRecords = await dairyRepo.getRecordsByDateRange(mStart, mEnd);
      double monthlyMilkTotal = 0.0;
      for (var r in monthlyRecords) {
        if (!r.isWithdrawn) monthlyMilkTotal += r.quantityLiters;
      }

      // 3. All Time Total
      final allRecords = await dairyRepo.getRecordsByDateRange(DateTime(2000), DateTime(2100));
      double allTimeMilkTotal = 0.0;
      for (var r in allRecords) {
        if (!r.isWithdrawn) allTimeMilkTotal += r.quantityLiters;
      }

      // 4. Analytics Data based on _currentFilter
      final analyticsData = await _calculateAnalytics(_currentFilter, tagMap);

      // 5. Store & Sales Metrics
      final storeMetrics = await dairyRepo.getMilkStoreMetrics();

      emit(DairyLoaded(
        dashboardRecords: dashboardRecords,
        totalMilkDashboard: totalMilkDashboard,
        averagePerCowDashboard: averagePerCowDashboard,
        topProducersDashboard: topProducersDashboard,
        lowPerformersDashboard: lowPerformersDashboard,
        cowsMilkedCount: cowsMilkedCount,
        monthlyMilkTotal: monthlyMilkTotal,
        allTimeMilkTotal: allTimeMilkTotal,
        selectedDashboardDate: _dashboardDate,
        dashboardFilter: _dashboardFilter,
        animalTagMap: tagMap,
        currentFilter: _currentFilter,
        herdChartData: analyticsData['chartData'] as List<double>,
        herdChartLabels: analyticsData['chartLabels'] as List<String>,
        cowYieldBreakdown: analyticsData['cowBreakdown'] as Map<String, double>,
        cowChartData: analyticsData['cowChartData'] as Map<String, List<double>>,
        totalYieldForPeriod: analyticsData['totalYield'] as double,
        currentMilkPrice: (storeMetrics['currentMilkPrice'] as num).toDouble(),
        totalCollectedLiters: (storeMetrics['totalCollectedLiters'] as num).toDouble(),
        totalWithdrawnLiters: (storeMetrics['totalWithdrawnLiters'] as num).toDouble(),
        totalSoldLiters: (storeMetrics['totalSoldLiters'] as num).toDouble(),
        totalRevenue: (storeMetrics['totalRevenue'] as num).toDouble(),
        inStoreLiters: (storeMetrics['inStoreLiters'] as num).toDouble(),
        inStoreValue: (storeMetrics['inStoreValue'] as num).toDouble(),
        salesHistory: storeMetrics['salesHistory'] as List<LocalTransaction>,
      ));
    } catch (e) {
      emit(DairyError(e.toString()));
    }
  }

  Future<void> _onAddMilkEntry(AddMilkEntry event, Emitter<DairyState> emit) async {
    try {
      await dairyRepo.addMilkRecord(event.recordData);
      add(LoadDairyData());
    } catch (e) {
      emit(DairyError(e.toString().replaceAll('Exception:', '').trim()));
      add(LoadDairyData());
    }
  }

  Future<void> _onUpdateMilkEntry(UpdateMilkEntry event, Emitter<DairyState> emit) async {
    try {
      await dairyRepo.updateMilkRecord(event.id, event.recordData);
      add(LoadDairyData());
    } catch (e) {
      emit(DairyError(e.toString().replaceAll('Exception:', '').trim()));
      add(LoadDairyData());
    }
  }

  Future<void> _onDeleteMilkEntry(DeleteMilkEntry event, Emitter<DairyState> emit) async {
    try {
      await dairyRepo.deleteMilkRecord(event.id);
      add(LoadDairyData());
    } catch (e) {
      emit(DairyError(e.toString().replaceAll('Exception:', '').trim()));
      add(LoadDairyData());
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
    
    if (filter == AnalyticsFilter.daily) {
      start = now.subtract(const Duration(days: 6));
      start = DateTime(start.year, start.month, start.day);
      points = 7;
    } else if (filter == AnalyticsFilter.weekly) {
      start = now.subtract(const Duration(days: 27));
      start = DateTime(start.year, start.month, start.day);
      points = 4;
    } else {
      start = DateTime(now.year, now.month - 11, 1);
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

      if (filter == AnalyticsFilter.daily) {
        final diff = r.recordDate.difference(start).inDays;
        if (diff >= 0 && diff < points) {
          chartData[diff] += r.quantityLiters;
          cowChartData[key]![diff] += r.quantityLiters;
        }
      } else if (filter == AnalyticsFilter.weekly) {
        final diffDays = r.recordDate.difference(start).inDays;
        final weekIdx = (diffDays / 7).floor();
        if (weekIdx >= 0 && weekIdx < points) {
          chartData[weekIdx] += r.quantityLiters;
          cowChartData[key]![weekIdx] += r.quantityLiters;
        }
      } else {
        final monthIdx = (r.recordDate.year - start.year) * 12 + (r.recordDate.month - start.month);
        if (monthIdx >= 0 && monthIdx < points) {
          chartData[monthIdx] += r.quantityLiters;
          cowChartData[key]![monthIdx] += r.quantityLiters;
        }
      }
    }

    List<String> labels = [];
    if (filter == AnalyticsFilter.daily) {
      final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      for (int i = 0; i < points; i++) {
        final d = start.add(Duration(days: i));
        labels.add(days[d.weekday % 7]);
      }
    } else if (filter == AnalyticsFilter.weekly) {
      for (int i = 0; i < points; i++) {
        labels.add('W${i + 1}');
      }
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      for (int i = 0; i < points; i++) {
        final m = (start.month - 1 + i) % 12;
        labels.add(months[m]);
      }
    }

    return {
      'chartData': chartData,
      'chartLabels': labels,
      'cowBreakdown': cowBreakdown,
      'cowChartData': cowChartData,
      'totalYield': totalYield,
    };
  }
}
