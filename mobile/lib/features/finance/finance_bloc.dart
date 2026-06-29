import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/local_db.dart';
import 'finance_repository.dart';

abstract class FinanceEvent {}
class LoadFinanceData extends FinanceEvent {}

abstract class FinanceState {}
class FinanceLoading extends FinanceState {}
class FinanceLoaded extends FinanceState {
  final List<LocalTransaction> transactions;
  final Map<String, double> sectorMargins;
  FinanceLoaded(this.transactions, this.sectorMargins);
}
class FinanceError extends FinanceState {
  final String message;
  FinanceError(this.message);
}

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final FinanceRepository repository;

  FinanceBloc(this.repository) : super(FinanceLoading()) {
    on<LoadFinanceData>((event, emit) async {
      emit(FinanceLoading());
      try {
        final transactions = await repository.getTransactions();
        
        // Calculate sector margins (demo logic)
        Map<String, double> margins = {
          'Dairy': 0,
          'Poultry': 0,
          'Hatchery': 0,
          'Livestock': 0,
        };

        for (var tx in transactions) {
          final amount = tx.transactionType == 'income' ? tx.amount : -tx.amount;
          if (margins.containsKey(tx.category)) {
            margins[tx.category] = (margins[tx.category] ?? 0) + amount;
          }
        }

        emit(FinanceLoaded(transactions, margins));
      } catch (e) {
        emit(FinanceError(e.toString()));
      }
    });
  }
}
