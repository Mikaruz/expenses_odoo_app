import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'expenses_database.g.dart';

@DataClassName('LocalExpenseRow')
class LocalExpenses extends Table {
  TextColumn get id => text()();
  TextColumn get accountScope => text()();
  IntColumn get remoteId => integer().nullable()();
  TextColumn get ruc => text().withDefault(const Constant(''))();
  TextColumn get businessName => text().withDefault(const Constant(''))();
  TextColumn get documentType => text().withDefault(const Constant(''))();
  TextColumn get documentNumber => text().withDefault(const Constant(''))();
  TextColumn get expenseDate => text().withDefault(const Constant(''))();
  IntColumn get subtotalCents => integer()();
  IntColumn get igvCents => integer()();
  IntColumn get totalCents => integer()();
  TextColumn get taxTreatment => text()();
  IntColumn get taxId => integer().nullable()();
  TextColumn get taxName => text().nullable()();
  RealColumn get taxRatePercentage => real()();
  TextColumn get receiptRelativePath => text()();
  TextColumn get syncStatus => text()();
  TextColumn get lastSyncError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [LocalExpenses])
class ExpensesDatabase extends _$ExpensesDatabase {
  ExpensesDatabase() : super(driftDatabase(name: 'oh_expenses'));

  ExpensesDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Stream<List<LocalExpenseRow>> watchExpenses(String accountScope) {
    final query = select(localExpenses)
      ..where((table) => table.accountScope.equals(accountScope))
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
    return query.watch();
  }

  Future<LocalExpenseRow?> getExpense(String id, String accountScope) {
    final query = select(localExpenses)
      ..where(
        (table) =>
            table.id.equals(id) & table.accountScope.equals(accountScope),
      );
    return query.getSingleOrNull();
  }

  Future<List<LocalExpenseRow>> getUnsyncedExpenses(String accountScope) {
    final query = select(localExpenses)
      ..where(
        (table) =>
            table.accountScope.equals(accountScope) &
            table.syncStatus.isNotValue('synced'),
      )
      ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]);
    return query.get();
  }

  Future<void> insertLocalExpense(LocalExpensesCompanion expense) {
    return into(localExpenses).insert(expense);
  }

  Future<void> updateLocalExpense(LocalExpensesCompanion expense) async {
    final query = update(localExpenses)
      ..where(
        (table) =>
            table.id.equals(expense.id.value) &
            table.accountScope.equals(expense.accountScope.value),
      );
    final updatedRows = await query.write(expense);
    if (updatedRows != 1) {
      throw StateError('Local expense not found');
    }
  }

  Future<void> reconcileRemoteExpenses({
    required String accountScope,
    required List<LocalExpensesCompanion> expenses,
  }) {
    return transaction(() async {
      final remoteIds = expenses
          .where((expense) => expense.remoteId.present)
          .map((expense) => expense.remoteId.value)
          .whereType<int>()
          .toList();
      final staleQuery = delete(localExpenses)
        ..where(
          (table) =>
              table.accountScope.equals(accountScope) &
              table.receiptRelativePath.equals('') &
              (remoteIds.isEmpty
                  ? const Constant(true)
                  : table.remoteId.isNotIn(remoteIds)),
        );
      await staleQuery.go();

      for (final expense in expenses) {
        final remoteId = expense.remoteId.value;
        if (remoteId == null) continue;
        final existingQuery = select(localExpenses)
          ..where(
            (table) =>
                table.accountScope.equals(accountScope) &
                table.remoteId.equals(remoteId),
          );
        final existing = await existingQuery.getSingleOrNull();
        if (existing == null) {
          await into(localExpenses).insert(expense);
        } else if (existing.receiptRelativePath.isEmpty) {
          await into(localExpenses).insertOnConflictUpdate(expense);
        }
      }
    });
  }

  Future<void> updateSyncState({
    required String id,
    required String accountScope,
    required int? remoteId,
    required String status,
    required String? errorMessage,
  }) {
    final query = update(localExpenses)
      ..where(
        (table) =>
            table.id.equals(id) & table.accountScope.equals(accountScope),
      );
    return query.write(
      LocalExpensesCompanion(
        remoteId: Value(remoteId),
        syncStatus: Value(status),
        lastSyncError: Value(errorMessage),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }
}
