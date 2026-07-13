import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/local_db.dart';
import 'inventory_repository.dart';
import '../../core/di/service_locator.dart';
import '../../core/network/notification_service.dart';

// ──────────────────────────────────────────────
// EVENTS
// ──────────────────────────────────────────────

abstract class InventoryEvent {}

class LoadInventoryItems extends InventoryEvent {}

class AddFeedItem extends InventoryEvent {
  final Map<String, dynamic> itemData;
  AddFeedItem(this.itemData);
}

class EditFeedItem extends InventoryEvent {
  final String itemId;
  final Map<String, dynamic> itemData;
  EditFeedItem(this.itemId, this.itemData);
}

class DeleteFeedItem extends InventoryEvent {
  final String itemId;
  DeleteFeedItem(this.itemId);
}

class AddInventoryLog extends InventoryEvent {
  final Map<String, dynamic> logData;
  AddInventoryLog(this.logData);
}

class LoadFeedFormulas extends InventoryEvent {}

class AddFeedFormula extends InventoryEvent {
  final Map<String, dynamic> data;
  AddFeedFormula(this.data);
}

class DeleteFeedFormula extends InventoryEvent {
  final String formulaId;
  DeleteFeedFormula(this.formulaId);
}

class AddFormulaIngredient extends InventoryEvent {
  final String formulaId;
  final Map<String, dynamic> data;
  AddFormulaIngredient(this.formulaId, this.data);
}

class RemoveFormulaIngredient extends InventoryEvent {
  final String ingredientId;
  RemoveFormulaIngredient(this.ingredientId);
}

class LogFeedConsumption extends InventoryEvent {
  final Map<String, dynamic> data;
  LogFeedConsumption(this.data);
}

class LoadConsumptionLogs extends InventoryEvent {
  final DateTime? date;
  final String? animalId;
  LoadConsumptionLogs({this.date, this.animalId});
}

class PrepareFormulaBatch extends InventoryEvent {
  final String formulaId;
  final double quantityKg;
  PrepareFormulaBatch(this.formulaId, this.quantityKg);
}

// ──────────────────────────────────────────────
// STATES
// ──────────────────────────────────────────────

abstract class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<dynamic> items;
  final List<dynamic> logs;
  final List<LocalFeedFormula> formulas;
  final List<LocalFeedConsumptionLog> consumptionLogs;
  InventoryLoaded(this.items, this.logs, this.formulas, this.consumptionLogs);
}

class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
}

// ──────────────────────────────────────────────
// BLOC
// ──────────────────────────────────────────────

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository repository;

  InventoryBloc(this.repository) : super(InventoryInitial()) {
    on<LoadInventoryItems>(_onLoad);
    on<AddFeedItem>(_onAddFeedItem);
    on<EditFeedItem>(_onEditFeedItem);
    on<DeleteFeedItem>(_onDeleteFeedItem);
    on<AddInventoryLog>(_onAddInventoryLog);
    on<AddFeedFormula>(_onAddFormula);
    on<DeleteFeedFormula>(_onDeleteFormula);
    on<AddFormulaIngredient>(_onAddIngredient);
    on<RemoveFormulaIngredient>(_onRemoveIngredient);
    on<LogFeedConsumption>(_onLogConsumption);
    on<LoadConsumptionLogs>(_onLoadConsumption);
    on<PrepareFormulaBatch>(_onPrepareFormulaBatch);
  }

  Future<void> _onLoad(LoadInventoryItems event, Emitter<InventoryState> emit) async {
    final currentState = state;
    if (currentState is! InventoryLoaded) {
      emit(InventoryLoading());
    }
    try {
      final items = await repository.getFeedItems();
      final logs = await repository.getInventoryLogs();
      final formulas = await repository.getFormulas();
      final consumption = await repository.getConsumptionLogs();
      emit(InventoryLoaded(items, logs, formulas, consumption));
    } catch (e) {
      if (currentState is! InventoryLoaded) {
        emit(InventoryError('Failed to load inventory: ${e.toString()}'));
      }
    }
  }

  Future<void> _onAddFeedItem(AddFeedItem event, Emitter<InventoryState> emit) async {
    try {
      await repository.addFeedItem(event.itemData);
      sl<NotificationService>().showLocalNotification(
        'Inventory Item Registered',
        'New item "${event.itemData['name']}" successfully registered.',
      );
      add(LoadInventoryItems());
    } catch (e) {
      emit(InventoryError('Failed to add feed item: ${e.toString()}'));
    }
  }

  Future<void> _onEditFeedItem(EditFeedItem event, Emitter<InventoryState> emit) async {
    try {
      await repository.updateFeedItem(event.itemId, event.itemData);
      add(LoadInventoryItems());
    } catch (e) {
      emit(InventoryError('Failed to edit feed item: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteFeedItem(DeleteFeedItem event, Emitter<InventoryState> emit) async {
    try {
      await repository.deleteFeedItem(event.itemId);
      add(LoadInventoryItems());
    } catch (e) {
      emit(InventoryError('Failed to delete feed item: ${e.toString()}'));
    }
  }

  Future<void> _onAddInventoryLog(AddInventoryLog event, Emitter<InventoryState> emit) async {
    try {
      await repository.logInventoryChange(event.logData);
      sl<NotificationService>().showLocalNotification(
        'Inventory Logged',
        'Stock change of ${event.logData['quantity']} registered.',
      );
      add(LoadInventoryItems());
    } catch (e) {
      emit(InventoryError('Failed to log inventory change: ${e.toString()}'));
    }
  }

  Future<void> _onAddFormula(AddFeedFormula event, Emitter<InventoryState> emit) async {
    try {
      await repository.addFormula(event.data);
      add(LoadInventoryItems());
    } catch (e) {
      emit(InventoryError('Failed to add formula: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteFormula(DeleteFeedFormula event, Emitter<InventoryState> emit) async {
    try {
      await repository.deleteFormula(event.formulaId);
      add(LoadInventoryItems());
    } catch (e) {
      emit(InventoryError('Failed to delete formula: ${e.toString()}'));
    }
  }

  Future<void> _onAddIngredient(AddFormulaIngredient event, Emitter<InventoryState> emit) async {
    try {
      await repository.addFormulaIngredient(event.formulaId, event.data);
      add(LoadInventoryItems());
    } catch (e) {
      emit(InventoryError('Failed to add ingredient: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveIngredient(RemoveFormulaIngredient event, Emitter<InventoryState> emit) async {
    try {
      await repository.removeFormulaIngredient(event.ingredientId);
      add(LoadInventoryItems());
    } catch (e) {
      emit(InventoryError('Failed to remove ingredient: ${e.toString()}'));
    }
  }

  Future<void> _onLogConsumption(LogFeedConsumption event, Emitter<InventoryState> emit) async {
    try {
      await repository.logConsumption(event.data);
      add(LoadInventoryItems());
    } catch (e) {
      emit(InventoryError('Failed to log consumption: ${e.toString()}'));
    }
  }

  Future<void> _onLoadConsumption(LoadConsumptionLogs event, Emitter<InventoryState> emit) async {
    // Just reload everything — the consumption logs will be part of InventoryLoaded
    add(LoadInventoryItems());
  }

  Future<void> _onPrepareFormulaBatch(PrepareFormulaBatch event, Emitter<InventoryState> emit) async {
    try {
      await repository.prepareFormulaBatch(event.formulaId, event.quantityKg);
      add(LoadInventoryItems());
    } catch (e) {
      emit(InventoryError('Failed to formulate feed: ${e.toString()}'));
    }
  }
}
