abstract class ReceiptStorageDatasource {
  Future<String> copyReceipt({
    required String sourcePath,
    required String receiptId,
  });

  Future<void> deleteReceipt(String relativePath);
  Future<String> resolvePath(String relativePath);
}
