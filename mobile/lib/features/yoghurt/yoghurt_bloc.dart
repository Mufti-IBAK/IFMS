import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/local_db.dart';
import '../../core/di/service_locator.dart';
import '../../core/sync/sync_event_bus.dart';
import '../dairy/dairy_repository.dart';
import 'yoghurt_repository.dart';

// Events
abstract class YoghurtEvent {}

class LoadYoghurtData extends YoghurtEvent {}

class UpdateYoghurtPriceEvent extends YoghurtEvent {
  final double pricePerBottle;
  final double pricePerPack;

  UpdateYoghurtPriceEvent({required this.pricePerBottle, required this.pricePerPack});
}

class TransferMilkToProductionEvent extends YoghurtEvent {
  final double quantityLiters;
  final String staffName;
  final String staffRole;

  TransferMilkToProductionEvent({
    required this.quantityLiters,
    this.staffName = 'Production Lead',
    this.staffRole = 'Production Lead',
  });
}

// ── BATCH EVENTS ─────────────────────────────────────────────────────────────
class RecordYoghurtBatchEvent extends YoghurtEvent {
  final DateTime productionDate;
  final double milkInputLiters;
  final int bottlesProduced;
  final double additionalCosts;
  final String? notes;

  RecordYoghurtBatchEvent({
    required this.productionDate,
    required this.milkInputLiters,
    required this.bottlesProduced,
    required this.additionalCosts,
    this.notes,
  });
}

class EditYoghurtBatchEvent extends YoghurtEvent {
  final String id;
  final DateTime productionDate;
  final double milkInputLiters;
  final int bottlesProduced;
  final double additionalCosts;
  final String? notes;

  EditYoghurtBatchEvent({
    required this.id,
    required this.productionDate,
    required this.milkInputLiters,
    required this.bottlesProduced,
    required this.additionalCosts,
    this.notes,
  });
}

class DeleteYoghurtBatchEvent extends YoghurtEvent {
  final String id;
  DeleteYoghurtBatchEvent(this.id);
}

// ── SALE EVENTS ──────────────────────────────────────────────────────────────
class RecordYoghurtSaleEvent extends YoghurtEvent {
  final DateTime saleDate;
  final String customerName;
  final String? customerPhone;
  final String? description;
  final String saleUnit;
  final int quantityUnits;
  final double unitPrice;
  final double amountPaid;
  final String? selectedBatchId;

  RecordYoghurtSaleEvent({
    required this.saleDate,
    required this.customerName,
    this.customerPhone,
    this.description,
    required this.saleUnit,
    required this.quantityUnits,
    required this.unitPrice,
    required this.amountPaid,
    this.selectedBatchId,
  });
}

class EditYoghurtSaleEvent extends YoghurtEvent {
  final String id;
  final DateTime saleDate;
  final String customerName;
  final String? customerPhone;
  final String? description;
  final String saleUnit;
  final int quantityUnits;
  final double unitPrice;
  final double amountPaid;
  final String? selectedBatchId;

  EditYoghurtSaleEvent({
    required this.id,
    required this.saleDate,
    required this.customerName,
    this.customerPhone,
    this.description,
    required this.saleUnit,
    required this.quantityUnits,
    required this.unitPrice,
    required this.amountPaid,
    this.selectedBatchId,
  });
}

class DeleteYoghurtSaleEvent extends YoghurtEvent {
  final String id;
  DeleteYoghurtSaleEvent(this.id);
}

// ── RETURN EVENTS ────────────────────────────────────────────────────────────
class RecordYoghurtReturnEvent extends YoghurtEvent {
  final DateTime returnDate;
  final String customerName;
  final String description;
  final int initialBoughtBottles;
  final int returnedBottles;
  final int replacedBottles;
  final String? selectedBatchId;

  RecordYoghurtReturnEvent({
    required this.returnDate,
    required this.customerName,
    required this.description,
    required this.initialBoughtBottles,
    required this.returnedBottles,
    required this.replacedBottles,
    this.selectedBatchId,
  });
}

class EditYoghurtReturnEvent extends YoghurtEvent {
  final String id;
  final DateTime returnDate;
  final String customerName;
  final String description;
  final int initialBoughtBottles;
  final int returnedBottles;
  final int replacedBottles;
  final String? selectedBatchId;

  EditYoghurtReturnEvent({
    required this.id,
    required this.returnDate,
    required this.customerName,
    required this.description,
    required this.initialBoughtBottles,
    required this.returnedBottles,
    required this.replacedBottles,
    this.selectedBatchId,
  });
}

class DeleteYoghurtReturnEvent extends YoghurtEvent {
  final String id;
  DeleteYoghurtReturnEvent(this.id);
}

// ── EXPENSE EVENTS ───────────────────────────────────────────────────────────
class RecordYoghurtExpenseEvent extends YoghurtEvent {
  final DateTime expenseDate;
  final String description;
  final String category;
  final double amount;

  RecordYoghurtExpenseEvent({
    required this.expenseDate,
    required this.description,
    required this.category,
    required this.amount,
  });
}

class EditYoghurtExpenseEvent extends YoghurtEvent {
  final String id;
  final DateTime expenseDate;
  final String description;
  final String category;
  final double amount;

  EditYoghurtExpenseEvent({
    required this.id,
    required this.expenseDate,
    required this.description,
    required this.category,
    required this.amount,
  });
}

class DeleteYoghurtExpenseEvent extends YoghurtEvent {
  final String id;
  DeleteYoghurtExpenseEvent(this.id);
}

// States
abstract class YoghurtState {}

class YoghurtInitial extends YoghurtState {}

class YoghurtLoading extends YoghurtState {}

class YoghurtLoaded extends YoghurtState {
  final int totalBottlesInStore;
  final int totalPacksInStore;
  final int todayBottlesProduced;
  final int monthlyBottlesProduced;
  final double totalRevenue;
  final double totalPaid;
  final double totalClientReceivables;
  final double totalFarmPayables;
  final int totalReplacedBottles;
  final double totalExpenses;
  final double pricePerBottle;
  final double pricePerPack;
  final Map<String, int> batchInventoryByDate;
  final List<LocalYoghurtSale> salesHistory;
  final List<LocalYoghurtBatche> batchHistory;
  final List<LocalYoghurtReturn> returnHistory;
  final List<LocalYoghurtExpense> expenseHistory;
  final double inStoreMilkLiters;
  final double currentMilkPrice;

  YoghurtLoaded({
    required this.totalBottlesInStore,
    required this.totalPacksInStore,
    required this.todayBottlesProduced,
    required this.monthlyBottlesProduced,
    required this.totalRevenue,
    required this.totalPaid,
    required this.totalClientReceivables,
    required this.totalFarmPayables,
    required this.totalReplacedBottles,
    required this.totalExpenses,
    required this.pricePerBottle,
    required this.pricePerPack,
    required this.batchInventoryByDate,
    required this.salesHistory,
    required this.batchHistory,
    required this.returnHistory,
    required this.expenseHistory,
    required this.inStoreMilkLiters,
    required this.currentMilkPrice,
  });
}

class YoghurtError extends YoghurtState {
  final String message;
  YoghurtError(this.message);
}

class YoghurtActionSuccess extends YoghurtState {
  final String message;
  YoghurtActionSuccess(this.message);
}

// BLoC
class YoghurtBloc extends Bloc<YoghurtEvent, YoghurtState> {
  final YoghurtRepository repository;
  StreamSubscription<SyncCompletedEvent>? _syncSubscription;

  YoghurtBloc(this.repository) : super(YoghurtInitial()) {
    _syncSubscription = SyncEventBus().stream.listen((event) {
      if (event.containsAny(['yoghurt', 'yoghurt_batches', 'yoghurt_sales', 'yoghurt_returns', 'yoghurt_expenses', 'milk_records'])) {
        add(LoadYoghurtData());
      }
    });

    on<LoadYoghurtData>((event, emit) async {
      emit(YoghurtLoading());
      try {
        final metrics = await repository.getYoghurtStoreMetrics();
        final dairyRepo = sl<DairyRepository>();
        final dairyMetrics = await dairyRepo.getMilkStoreMetrics();
        final milkPrice = await dairyRepo.getMilkPrice();

        emit(YoghurtLoaded(
          totalBottlesInStore: metrics['totalBottlesInStore'] as int,
          totalPacksInStore: metrics['totalPacksInStore'] as int,
          todayBottlesProduced: metrics['todayBottlesProduced'] as int,
          monthlyBottlesProduced: metrics['monthlyBottlesProduced'] as int,
          totalRevenue: (metrics['totalRevenue'] as num).toDouble(),
          totalPaid: (metrics['totalPaid'] as num).toDouble(),
          totalClientReceivables: (metrics['totalClientReceivables'] as num).toDouble(),
          totalFarmPayables: (metrics['totalFarmPayables'] as num).toDouble(),
          totalReplacedBottles: metrics['totalReplacedBottles'] as int,
          totalExpenses: (metrics['totalExpenses'] as num?)?.toDouble() ?? 0.0,
          pricePerBottle: (metrics['pricePerBottle'] as num?)?.toDouble() ?? 500.0,
          pricePerPack: (metrics['pricePerPack'] as num?)?.toDouble() ?? 6000.0,
          batchInventoryByDate: Map<String, int>.from(metrics['batchInventoryByDate'] as Map),
          salesHistory: List<LocalYoghurtSale>.from(metrics['salesHistory'] as List),
          batchHistory: List<LocalYoghurtBatche>.from(metrics['batchHistory'] as List),
          returnHistory: List<LocalYoghurtReturn>.from(metrics['returnHistory'] as List),
          expenseHistory: List<LocalYoghurtExpense>.from(metrics['expenseHistory'] as List),
          inStoreMilkLiters: (dairyMetrics['inStoreLiters'] as num?)?.toDouble() ?? 0.0,
          currentMilkPrice: milkPrice,
        ));
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });

    on<UpdateYoghurtPriceEvent>((event, emit) async {
      emit(YoghurtLoading());
      try {
        await repository.updateYoghurtPrices(
          pricePerBottle: event.pricePerBottle,
          pricePerPack: event.pricePerPack,
        );
        emit(YoghurtActionSuccess('Updated Yoghurt Selling Prices.'));
        add(LoadYoghurtData());
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });

    on<TransferMilkToProductionEvent>((event, emit) async {
      emit(YoghurtLoading());
      try {
        await repository.transferMilkToProduction(
          quantityLiters: event.quantityLiters,
          staffName: event.staffName,
          staffRole: event.staffRole,
        );
        emit(YoghurtActionSuccess('Successfully transferred ${event.quantityLiters.toStringAsFixed(1)} L raw milk to Yoghurt Production.'));
        add(LoadYoghurtData());
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });

    // ── BATCH HANDLERS ──────────────────────────────────────────────────────
    on<RecordYoghurtBatchEvent>((event, emit) async {
      emit(YoghurtLoading());
      try {
        await repository.recordYoghurtBatch(
          productionDate: event.productionDate,
          milkInputLiters: event.milkInputLiters,
          bottlesProduced: event.bottlesProduced,
          additionalCosts: event.additionalCosts,
          notes: event.notes,
        );
        emit(YoghurtActionSuccess('Recorded production batch of ${event.bottlesProduced} bottles.'));
        add(LoadYoghurtData());
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });

    on<EditYoghurtBatchEvent>((event, emit) async {
      emit(YoghurtLoading());
      try {
        await repository.updateYoghurtBatch(
          id: event.id,
          productionDate: event.productionDate,
          milkInputLiters: event.milkInputLiters,
          bottlesProduced: event.bottlesProduced,
          additionalCosts: event.additionalCosts,
          notes: event.notes,
        );
        emit(YoghurtActionSuccess('Updated production batch.'));
        add(LoadYoghurtData());
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });

    on<DeleteYoghurtBatchEvent>((event, emit) async {
      emit(YoghurtLoading());
      try {
        await repository.deleteYoghurtBatch(event.id);
        emit(YoghurtActionSuccess('Deleted production batch.'));
        add(LoadYoghurtData());
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });

    // ── SALE HANDLERS ───────────────────────────────────────────────────────
    on<RecordYoghurtSaleEvent>((event, emit) async {
      emit(YoghurtLoading());
      try {
        await repository.recordYoghurtSale(
          saleDate: event.saleDate,
          customerName: event.customerName,
          customerPhone: event.customerPhone,
          description: event.description,
          saleUnit: event.saleUnit,
          quantityUnits: event.quantityUnits,
          unitPrice: event.unitPrice,
          amountPaid: event.amountPaid,
          selectedBatchId: event.selectedBatchId,
        );
        emit(YoghurtActionSuccess('Recorded yoghurt sale to ${event.customerName}.'));
        add(LoadYoghurtData());
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });

    on<EditYoghurtSaleEvent>((event, emit) async {
      emit(YoghurtLoading());
      try {
        await repository.updateYoghurtSale(
          id: event.id,
          saleDate: event.saleDate,
          customerName: event.customerName,
          customerPhone: event.customerPhone,
          description: event.description,
          saleUnit: event.saleUnit,
          quantityUnits: event.quantityUnits,
          unitPrice: event.unitPrice,
          amountPaid: event.amountPaid,
          selectedBatchId: event.selectedBatchId,
        );
        emit(YoghurtActionSuccess('Updated sale entry for ${event.customerName}.'));
        add(LoadYoghurtData());
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });

    on<DeleteYoghurtSaleEvent>((event, emit) async {
      emit(YoghurtLoading());
      try {
        await repository.deleteYoghurtSale(event.id);
        emit(YoghurtActionSuccess('Deleted sale entry.'));
        add(LoadYoghurtData());
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });

    // ── RETURN HANDLERS ─────────────────────────────────────────────────────
    on<RecordYoghurtReturnEvent>((event, emit) async {
      emit(YoghurtLoading());
      try {
        await repository.recordYoghurtReturn(
          returnDate: event.returnDate,
          customerName: event.customerName,
          description: event.description,
          initialBoughtBottles: event.initialBoughtBottles,
          returnedBottles: event.returnedBottles,
          replacedBottles: event.replacedBottles,
          selectedBatchId: event.selectedBatchId,
        );
        emit(YoghurtActionSuccess('Recorded product return from ${event.customerName}.'));
        add(LoadYoghurtData());
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });

    on<EditYoghurtReturnEvent>((event, emit) async {
      emit(YoghurtLoading());
      try {
        await repository.updateYoghurtReturn(
          id: event.id,
          returnDate: event.returnDate,
          customerName: event.customerName,
          description: event.description,
          initialBoughtBottles: event.initialBoughtBottles,
          returnedBottles: event.returnedBottles,
          replacedBottles: event.replacedBottles,
          selectedBatchId: event.selectedBatchId,
        );
        emit(YoghurtActionSuccess('Updated product return record.'));
        add(LoadYoghurtData());
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });

    on<DeleteYoghurtReturnEvent>((event, emit) async {
      emit(YoghurtLoading());
      try {
        await repository.deleteYoghurtReturn(event.id);
        emit(YoghurtActionSuccess('Deleted product return record.'));
        add(LoadYoghurtData());
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });

    // ── EXPENSE HANDLERS ────────────────────────────────────────────────────
    on<RecordYoghurtExpenseEvent>((event, emit) async {
      emit(YoghurtLoading());
      try {
        await repository.recordYoghurtExpense(
          expenseDate: event.expenseDate,
          description: event.description,
          category: event.category,
          amount: event.amount,
        );
        emit(YoghurtActionSuccess('Recorded yoghurt operational expense.'));
        add(LoadYoghurtData());
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });

    on<EditYoghurtExpenseEvent>((event, emit) async {
      emit(YoghurtLoading());
      try {
        await repository.updateYoghurtExpense(
          id: event.id,
          expenseDate: event.expenseDate,
          description: event.description,
          category: event.category,
          amount: event.amount,
        );
        emit(YoghurtActionSuccess('Updated operational expense record.'));
        add(LoadYoghurtData());
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });

    on<DeleteYoghurtExpenseEvent>((event, emit) async {
      emit(YoghurtLoading());
      try {
        await repository.deleteYoghurtExpense(event.id);
        emit(YoghurtActionSuccess('Deleted operational expense record.'));
        add(LoadYoghurtData());
      } catch (e) {
        emit(YoghurtError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _syncSubscription?.cancel();
    return super.close();
  }
}
