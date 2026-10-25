import 'dart:convert';

import 'package:oh_expenses_app/features/auth/auth.dart';
import 'package:oh_expenses_app/features/config/domain/domain.dart';
import 'package:oh_expenses_app/features/config/infrastructure/infrastructure.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expense_products_provider.g.dart';

class ExpenseProductsState {
  final bool isLoading;
  final bool hasLoaded;
  final List<ExpenseProduct> products;
  final String errorMessage;

  const ExpenseProductsState({
    this.isLoading = false,
    this.hasLoaded = false,
    this.products = const [],
    this.errorMessage = '',
  });

  ExpenseProductsState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    List<ExpenseProduct>? products,
    String? errorMessage,
  }) {
    return ExpenseProductsState(
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
class ExpenseProductsNotifier extends _$ExpenseProductsNotifier {
  late final ExpenseProductsRepository _repository =
      ExpenseProductsRepositoryImpl(ExpenseProductsDatasourceImpl());
  late final KeyValueStorageService _storage;
  String? _loadedCacheKey;

  @override
  ExpenseProductsState build() {
    _storage = KeyValueStorageServiceImpl();
    return const ExpenseProductsState();
  }

  Future<void> loadProducts({bool force = false}) async {
    if (state.isLoading) return;

    await ref.read(authProvider.notifier).ensureOnlineSession();
    final authState = ref.read(authProvider);
    final user = authState.user;
    final odooUrl = await _storage.getValue<String>('odooUrl');
    final database = await _storage.getValue<String>('odooDatabase');
    if (user == null || odooUrl == null || database == null) {
      state = state.copyWith(
        hasLoaded: true,
        errorMessage: 'Faltan datos de conexión para consultar categorías.',
      );
      return;
    }

    final cacheKey = _cacheKey(odooUrl, database, user.uid);
    if (!force && _loadedCacheKey == cacheKey && state.hasLoaded) return;
    _loadedCacheKey = cacheKey;

    final cachedProducts = await _readCache(cacheKey);
    if (cachedProducts.isNotEmpty) {
      state = state.copyWith(
        hasLoaded: true,
        products: cachedProducts,
        errorMessage: '',
      );
    }

    if (authState.isOffline || user.sessionId.trim().isEmpty) {
      state = state.copyWith(
        hasLoaded: true,
        errorMessage: cachedProducts.isEmpty
            ? 'Conéctate a Odoo para cargar las categorías de gasto.'
            : '',
      );
      return;
    }

    final userId = int.tryParse(user.uid);
    if (userId == null || userId <= 0) {
      state = state.copyWith(
        hasLoaded: true,
        errorMessage: 'La sesión de Odoo no tiene un usuario válido.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final products = await _repository.getProducts(
        odooUrl: odooUrl,
        database: database,
        sessionId: user.sessionId,
        userId: userId,
      );
      await _writeCache(cacheKey, products);
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        products: products,
        errorMessage: '',
      );
    } on CustomError catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessage: cachedProducts.isEmpty
            ? error.message
            : 'No se pudo actualizar el catálogo; se usará la última versión.',
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessage: cachedProducts.isEmpty
            ? 'No se pudieron cargar las categorías desde Odoo.'
            : 'No se pudo actualizar el catálogo; se usará la última versión.',
      );
    }
  }

  Future<List<ExpenseProduct>> _readCache(String cacheKey) async {
    final value = await _storage.getValue<String>(cacheKey);
    if (value == null || value.isEmpty) return const [];
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map(
            (item) => ExpenseProduct.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((product) => product.id > 0 && product.name.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _writeCache(
    String cacheKey,
    List<ExpenseProduct> products,
  ) async {
    await _storage.setKeyValue(
      cacheKey,
      jsonEncode(products.map((product) => product.toJson()).toList()),
    );
  }

  String _cacheKey(String odooUrl, String database, String uid) {
    return 'expense-products:${Uri.encodeComponent('${odooUrl.trim()}|${database.trim()}|$uid')}';
  }
}
