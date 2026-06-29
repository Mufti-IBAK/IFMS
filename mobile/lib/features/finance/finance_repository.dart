import 'package:drift/drift.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';

class FinanceRepository {
  final ApiClient apiClient;
  final LocalDatabase db;

  FinanceRepository(this.apiClient, this.db);

  Future<List<LocalTransaction>> getTransactions() async {
    try {
      final response = await apiClient.dio.get('/finance/transactions');
      final list = response.data as List;
      await _syncTransactions(list);
    } catch (_) {}
    return await db.select(db.localTransactions).get();
  }

  Future<void> _syncTransactions(List<dynamic> remoteData) async {
    await db.delete(db.localTransactions).go();
    for (var item in remoteData) {
      await db.into(db.localTransactions).insertOnConflictUpdate(LocalTransactionsCompanion.insert(
        id: item['id'],
        transactionType: item['transaction_type'],
        category: item['category'],
        amount: item['amount'].toDouble(),
        currency: Value(item['currency'] ?? 'NGN'),
        relatedEntityType: Value(item['related_entity_type']),
        relatedEntityId: Value(item['related_entity_id']),
        description: Value(item['description']),
        transactionDate: DateTime.parse(item['transaction_date']),
        isReconciled: Value(item['is_reconciled'] ?? false),
      ));
    }
  }
}
