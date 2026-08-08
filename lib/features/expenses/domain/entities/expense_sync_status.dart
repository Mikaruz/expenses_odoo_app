enum ExpenseSyncStatus {
  pending,
  synced,
  error;

  static ExpenseSyncStatus fromStorage(String value) {
    return ExpenseSyncStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ExpenseSyncStatus.pending,
    );
  }
}
