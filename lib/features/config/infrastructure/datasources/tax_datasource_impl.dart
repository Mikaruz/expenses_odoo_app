import 'package:dio/dio.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/config/config.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';

class TaxDatasourceImpl extends TaxDatasource {
  @override
  Future<List<ExpenseTax>> getTaxes({
    required String odooUrl,
    required String database,
    required String sessionId,
  }) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: odooUrl.trim(),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'session_id=$sessionId',
          },
        ),
      );

      final domain = _buildTaxDomain();

      final response = await dio.post(
        '/web/dataset/call_kw/account.tax/search_read',
        data: _jsonrpc(
          params: {
            'model': 'account.tax',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'domain': domain,
              'fields': ['id', 'name', 'amount', 'amount_type', 'type_tax_use'],
              'order': 'name',
            },
          },
        ),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw CustomError('Respuesta inválida al consultar impuestos.');
      }

      final error = data['error'];
      if (error != null) {
        final errorData = error is Map<String, dynamic> ? error['data'] : null;
        final message = errorData is Map<String, dynamic>
            ? errorData['message']
            : null;
        final errorMessage = message?.toString().isNotEmpty == true
            ? message.toString()
            : 'No se pudieron obtener los impuestos desde Odoo.';
        Logger.error('Error al listar impuestos de Odoo: $errorMessage');
        throw CustomError(errorMessage);
      }

      final result = data['result'];
      if (result is! List) {
        throw CustomError('Odoo no devolvió una lista de impuestos válida.');
      }

      return result
          .whereType<Map<String, dynamic>>()
          .map(TaxMapper.odooJsonToEntity)
          .toList();
    } on DioException catch (e) {
      handleDioError(e);
    } on CustomError {
      rethrow;
    } catch (e) {
      Logger.error(e.toString());
      throw CustomError('Error consultando impuestos: ${e.toString()}');
    }
  }

  /// Replica el dominio funcional de tax_ids en hr.expense. Las reglas de
  /// compañía de la sesión de Odoo determinan qué registros son visibles.
  List<Object> _buildTaxDomain() {
    return [
      ['type_tax_use', '=', 'purchase'],
    ];
  }

  Map<String, Object?> _jsonrpc({required Map<String, Object?> params}) {
    return {
      'jsonrpc': '2.0',
      'method': 'call',
      'params': params,
      'id': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
