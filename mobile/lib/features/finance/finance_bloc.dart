import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/local_db.dart';
import 'finance_repository.dart';

// ──────────────────────────────────────────────
// EVENTS
// ──────────────────────────────────────────────

abstract class FinanceEvent {}

class LoadFinanceData extends FinanceEvent {}

class AddTransaction extends FinanceEvent {
  final Map<String, dynamic> data;
  AddTransaction(this.data);
}

class ReconcileTransactionEvent extends FinanceEvent {
  final String id;
  ReconcileTransactionEvent(this.id);
}

class ReverseTransactionEvent extends FinanceEvent {
  final String id;
  ReverseTransactionEvent(this.id);
}

class UpdateTransactionEvent extends FinanceEvent {
  final String id;
  final Map<String, dynamic> data;
  UpdateTransactionEvent(this.id, this.data);
}

class DeleteTransactionEvent extends FinanceEvent {
  final String id;
  DeleteTransactionEvent(this.id);
}

class ClearAllTransactionsEvent extends FinanceEvent {}

// ──────────────────────────────────────────────
// STATES
// ──────────────────────────────────────────────

abstract class FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {
  final List<LocalTransaction> transactions;
  final Map<String, double> sectorMargins;
  final Map<String, dynamic> overallProfit;
  final List<dynamic> cullingRecommendations;

  FinanceLoaded({
    required this.transactions,
    required this.sectorMargins,
    required this.overallProfit,
    required this.cullingRecommendations,
  });
}

class FinanceError extends FinanceState {
  final String message;
  FinanceError(this.message);
}

// ──────────────────────────────────────────────
// BLOC
// ──────────────────────────────────────────────

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final FinanceRepository repository;

  FinanceBloc(this.repository) : super(FinanceLoading()) {
    on<LoadFinanceData>(_onLoad);
    on<AddTransaction>(_onAddTransaction);
    on<ReconcileTransactionEvent>(_onReconcile);
    on<ReverseTransactionEvent>(_onReverse);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<ClearAllTransactionsEvent>(_onClearAllTransactions);
  }

  Future<void> _onLoad(LoadFinanceData event, Emitter<FinanceState> emit) async {
    final currentState = state;
    if (currentState is! FinanceLoaded) {
      emit(FinanceLoading());
    }
    try {
      final transactions = await repository.getTransactions();
      final overallProfit = await repository.getOverallFarmProfit();
      final culling = await repository.getCullingRecommendations();

      // Sector Net Margin breakdown
      Map<String, double> sectorMargins = {
        'Dairy (milk_sales)': 0,
        'Poultry (poultry_sales)': 0,
        'Hatchery (hatchery_sales)': 0,
        'Livestock (animal_sales)': 0,
      };

      for (var tx in transactions) {
        final amount = tx.transactionType == 'income' ? tx.amount : -tx.amount;
        if (tx.category == 'milk_sales') {
          sectorMargins['Dairy (milk_sales)'] = (sectorMargins['Dairy (milk_sales)'] ?? 0) + amount;
        } else if (tx.category == 'poultry_sales') {
          sectorMargins['Poultry (poultry_sales)'] = (sectorMargins['Poultry (poultry_sales)'] ?? 0) + amount;
        } else if (tx.category == 'hatchery_sales') {
          sectorMargins['Hatchery (hatchery_sales)'] = (sectorMargins['Hatchery (hatchery_sales)'] ?? 0) + amount;
        } else if (tx.category == 'animal_sales') {
          sectorMargins['Livestock (animal_sales)'] = (sectorMargins['Livestock (animal_sales)'] ?? 0) + amount;
        }
      }

      emit(FinanceLoaded(
        transactions: transactions,
        sectorMargins: sectorMargins,
        overallProfit: overallProfit,
        cullingRecommendations: culling,
      ));
    } catch (e) {
      if (currentState is! FinanceLoaded) {
        emit(FinanceError('Failed to load financials: ${e.toString()}'));
      }
    }
  }

  Future<void> _onAddTransaction(AddTransaction event, Emitter<FinanceState> emit) async {
    try {
      await repository.addTransaction(event.data);
      add(LoadFinanceData());
    } catch (e) {
      emit(FinanceError(e.toString().replaceAll('Exception:', '').trim()));
      add(LoadFinanceData());
    }
  }

  Future<void> _onReconcile(ReconcileTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.reconcileTransaction(event.id);
      add(LoadFinanceData());
    } catch (e) {
      emit(FinanceError(e.toString().replaceAll('Exception:', '').trim()));
      add(LoadFinanceData());
    }
  }

  Future<void> _onReverse(ReverseTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.reverseTransaction(event.id);
      add(LoadFinanceData());
    } catch (e) {
      emit(FinanceError(e.toString().replaceAll('Exception:', '').trim()));
      add(LoadFinanceData());
    }
  }

  Future<void> _onUpdateTransaction(UpdateTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.updateTransaction(event.id, event.data);
      add(LoadFinanceData());
    } catch (e) {
      emit(FinanceError(e.toString().replaceAll('Exception:', '').trim()));
      add(LoadFinanceData());
    }
  }

  Future<void> _onDeleteTransaction(DeleteTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.deleteTransaction(event.id);
      add(LoadFinanceData());
    } catch (e) {
      emit(FinanceError(e.toString().replaceAll('Exception:', '').trim()));
      add(LoadFinanceData());
    }
  }

  Future<void> _onClearAllTransactions(ClearAllTransactionsEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.clearAllTransactions();
      add(LoadFinanceData());
    } catch (e) {
      emit(FinanceError(e.toString().replaceAll('Exception:', '').trim()));
      add(LoadFinanceData());
    }
  }
}
