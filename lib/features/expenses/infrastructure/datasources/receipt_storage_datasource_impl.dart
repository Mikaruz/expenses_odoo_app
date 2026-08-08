import 'dart:io';

import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/domain.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ReceiptStorageDatasourceImpl extends ReceiptStorageDatasource {
  String? _supportDirectoryPath;

  @override
  Future<String> copyReceipt({
    required String sourcePath,
    required String receiptId,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw CustomError('No se encontró la imagen del comprobante.');
    }

    try {
      final supportPath = await _getSupportDirectoryPath();
      final receiptsDirectory = Directory(path.join(supportPath, 'receipts'));
      await receiptsDirectory.create(recursive: true);

      final extension = path.extension(sourcePath).toLowerCase();
      final fileName = '$receiptId${extension.isEmpty ? '.jpg' : extension}';
      final destination = path.join(receiptsDirectory.path, fileName);
      await source.copy(destination);

      Logger.success('[Receipt][$receiptId] comprobante almacenado localmente');
      return path.join('receipts', fileName);
    } catch (error) {
      Logger.error(
        '[Receipt][$receiptId] error al copiar el comprobante: $error',
      );
      throw CustomError('No se pudo guardar la imagen del comprobante.');
    }
  }

  @override
  Future<void> deleteReceipt(String relativePath) async {
    try {
      final file = File(await resolvePath(relativePath));
      if (await file.exists()) await file.delete();
    } catch (error) {
      Logger.warning('[Receipt] no se pudo limpiar un archivo local: $error');
    }
  }

  @override
  Future<String> resolvePath(String relativePath) async {
    final supportPath = await _getSupportDirectoryPath();
    return path.join(supportPath, relativePath);
  }

  Future<String> _getSupportDirectoryPath() async {
    if (_supportDirectoryPath != null) return _supportDirectoryPath!;
    final directory = await getApplicationSupportDirectory();
    _supportDirectoryPath = directory.path;
    return directory.path;
  }
}
