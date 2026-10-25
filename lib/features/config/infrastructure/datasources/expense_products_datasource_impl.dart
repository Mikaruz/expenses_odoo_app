import 'package:dio/dio.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/config/config.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';

class ExpenseProductsDatasourceImpl extends ExpenseProductsDatasource {
  @override
  Future<List<ExpenseProduct>> getProducts({
    required String odooUrl,
    required String database,
    required String sessionId,
    required int userId,
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
            'X-Odoo-Database': database.trim(),
          },
        ),
      );

      final companyId = await _getCurrentCompanyId(dio, userId);
      final response = await dio.post(
        '/web/dataset/call_kw/product.product/search_read',
        data: _jsonrpc(
          params: {
            'model': 'product.product',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'domain': [
                '|',
                ['company_id', '=', false],
                [
                  'company_id',
                  'parent_of',
                  [companyId],
                ],
                ['can_be_expensed', '=', true],
              ],
              'fields': [
                'id',
                'name',
                'display_name',
                'default_code',
                'company_id',
                'can_be_expensed',
              ],
              'order': 'name, id',
              'context': {
                'lang': 'es_PE',
                'default_type': 'service',
                'default_can_be_expensed': 1,
                'list_view_ref': 'hr_expense.product_product_expense_tree_view',
                'form_view_ref': 'hr_expense.product_product_expense_form_view',
              },
            },
          },
        ),
      );

      final data = _readResponse(response.data);
      final result = data['result'];
      if (result is! List) {
        throw CustomError('Odoo no devolvió una lista de categorías válida.');
      }

      return result
          .whereType<Map<String, dynamic>>()
          .map(ExpenseProductMapper.odooJsonToEntity)
          .where((product) => product.id > 0 && product.name.isNotEmpty)
          .toList();
    } on DioException catch (error) {
      handleDioError(error);
    } on CustomError {
      rethrow;
    } catch (error) {
      Logger.error('Error consultando categorías de Odoo: $error');
      throw CustomError('No se pudieron consultar las categorías de Odoo.');
    }
  }

  Future<int> _getCurrentCompanyId(Dio dio, int userId) async {
    final response = await dio.post(
      '/web/dataset/call_kw/res.users/search_read',
      data: _jsonrpc(
        params: {
          'model': 'res.users',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['id', '=', userId],
            ],
            'fields': ['company_id'],
            'limit': 1,
          },
        },
      ),
    );
    final data = _readResponse(response.data);
    final result = data['result'];
    if (result is! List || result.isEmpty || result.first is! Map) {
      throw CustomError('No se pudo identificar la compañía activa de Odoo.');
    }
    final company = (result.first as Map)['company_id'];
    final companyId = company is List
        ? int.tryParse(company.firstOrNull?.toString() ?? '')
        : int.tryParse(company?.toString() ?? '');
    if (companyId == null || companyId <= 0) {
      throw CustomError('Odoo no devolvió una compañía activa válida.');
    }
    return companyId;
  }

  Map<String, dynamic> _readResponse(Object? response) {
    if (response is! Map<String, dynamic>) {
      throw CustomError('Odoo devolvió una respuesta inválida.');
    }
    final error = response['error'];
    if (error != null) {
      final errorData = error is Map<String, dynamic> ? error['data'] : null;
      final message = errorData is Map<String, dynamic>
          ? errorData['message']
          : null;
      throw CustomError(
        message?.toString().isNotEmpty == true
            ? message.toString()
            : 'Odoo rechazó la consulta de categorías.',
      );
    }
    return response;
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
