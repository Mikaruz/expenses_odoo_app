import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/entities/expense_draft.dart';
import 'package:oh_expenses_app/features/expenses/domain/entities/local_expense.dart';
import 'package:oh_expenses_app/features/expenses/domain/entities/ocr_expense_result.dart';
import 'package:oh_expenses_app/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:oh_expenses_app/features/expenses/presentation/providers/ocr_provider.dart';
import 'package:oh_expenses_app/features/expenses/utils/expense_amount_validator.dart';
import 'package:oh_expenses_app/features/expenses/utils/expense_amount_sync.dart';
import 'package:oh_expenses_app/features/expenses/utils/money_utils.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final LocalExpense? expense;

  const ExpenseFormScreen({super.key, this.expense});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _rucController;
  late TextEditingController _businessNameController;
  late TextEditingController _typeController;
  late TextEditingController _dateController;
  late TextEditingController _serialController;
  late TextEditingController _subtotalController;
  late TextEditingController _igvController;
  late TextEditingController _totalController;
  int? _selectedProductId;
  String? _selectedProductName;
  String? _amountsError;
  String? _saveError;
  String? _editImagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final ocrState = ref.read(ocrProvider);
    final result = ocrState.result;
    final expense = widget.expense;
    _selectedProductId = expense?.productId;
    _selectedProductName = expense?.productName == null
        ? null
        : ExpenseProduct.normalizeName(expense!.productName!);

    _rucController = TextEditingController(
      text: expense?.ruc ?? result?.ruc ?? '',
    );
    _businessNameController = TextEditingController(
      text: expense?.businessName ?? result?.businessName ?? '',
    );
    _typeController = TextEditingController(
      text: expense?.documentType ?? result?.type ?? '',
    );
    _dateController = TextEditingController(
      text: expense?.date ?? result?.date ?? '',
    );
    _serialController = TextEditingController(
      text: expense?.documentNumber ?? result?.serialNumber ?? '',
    );
    _subtotalController = TextEditingController(
      text: expense != null
          ? expense.subtotal.toStringAsFixed(2)
          : (result?.subtotal ?? 0) > 0
          ? result!.subtotal.toStringAsFixed(2)
          : '',
    );
    _igvController = TextEditingController(
      text: expense != null
          ? expense.igv.toStringAsFixed(2)
          : result == null
          ? ''
          : result.igv.toStringAsFixed(2),
    );
    _totalController = TextEditingController(
      text: expense != null
          ? expense.total.toStringAsFixed(2)
          : (result?.total ?? 0) > 0
          ? result!.total.toStringAsFixed(2)
          : '',
    );
    if (expense != null && expense.receiptRelativePath.isNotEmpty) {
      _loadEditImage(expense.receiptRelativePath);
    }
    Future.microtask(
      () => ref.read(expenseProductsProvider.notifier).loadProducts(),
    );
  }

  Future<void> _loadEditImage(String relativePath) async {
    final path = await ref
        .read(localExpensesRepositoryProvider)
        .resolveReceiptPath(relativePath);
    if (mounted) setState(() => _editImagePath = path);
  }

  @override
  void dispose() {
    _rucController.dispose();
    _businessNameController.dispose();
    _typeController.dispose();
    _dateController.dispose();
    _serialController.dispose();
    _subtotalController.dispose();
    _igvController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    FocusScope.of(context).unfocus();

    if (_isSaving || !_formKey.currentState!.validate()) return;

    if (_selectedProductId == null || _selectedProductId! <= 0) {
      setState(() => _saveError = 'Selecciona una categoría de gasto.');
      return;
    }

    final result = ref.read(ocrProvider).result;
    final imagePath = widget.expense == null
        ? ref.read(ocrProvider).imagePath
        : _editImagePath;
    final settings = ref.read(taxSettingsProvider);
    final taxTreatment =
        widget.expense?.taxTreatment ??
        result?.taxTreatment ??
        ExpenseTaxTreatment.unknown;
    final ratePercentage =
        widget.expense?.taxRatePercentage ?? settings.ratePercentage;
    final subtotalCents = MoneyUtils.parseCents(_subtotalController.text);
    final igvCents = MoneyUtils.parseCents(_igvController.text);
    final totalCents = MoneyUtils.parseCents(_totalController.text);
    final validation = ExpenseAmountValidator.validate(
      subtotal: MoneyUtils.parse(_subtotalController.text),
      igv: MoneyUtils.parse(_igvController.text),
      total: MoneyUtils.parse(_totalController.text),
      taxTreatment: taxTreatment,
      ratePercentage: ratePercentage,
    );

    if (!validation.isValid) {
      setState(() => _amountsError = validation.errorMessage);
      return;
    }

    if ((widget.expense == null && imagePath == null) ||
        subtotalCents == null ||
        igvCents == null ||
        totalCents == null) {
      setState(
        () => _saveError = 'No se pudo preparar el gasto para guardarlo.',
      );
      return;
    }

    setState(() {
      _amountsError = null;
      _saveError = null;
      _isSaving = true;
    });

    try {
      final accountScope = await ref.read(currentAccountScopeProvider.future);
      if (accountScope == null) {
        throw CustomError('No se encontró el perfil local del usuario.');
      }

      final draft = ExpenseDraft(
        ruc: _rucController.text.trim(),
        businessName: _businessNameController.text.trim(),
        documentType: _typeController.text.trim(),
        documentNumber: _serialController.text.trim(),
        productId: _selectedProductId,
        productName: _selectedProductName,
        date: _dateController.text.trim(),
        subtotalCents: subtotalCents,
        igvCents: igvCents,
        totalCents: totalCents,
        taxTreatment: taxTreatment,
        taxId: widget.expense?.taxId ?? settings.taxId,
        taxName: widget.expense?.taxName ?? settings.taxName,
        taxRatePercentage: ratePercentage,
      );

      final repository = ref.read(localExpensesRepositoryProvider);
      final expense = widget.expense == null
          ? await repository.saveExpense(
              draft: draft,
              sourceImagePath: imagePath!,
              accountScope: accountScope,
            )
          : await repository.updateExpense(
              expense: widget.expense!,
              draft: draft,
            );
      final wasSynced = await ref
          .read(expenseSyncProvider.notifier)
          .syncExpense(expense);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasSynced
                ? 'Gasto ${widget.expense == null ? 'guardado' : 'actualizado'} y sincronizado con Odoo'
                : 'Gasto ${widget.expense == null ? 'guardado' : 'actualizado'} localmente; sincronización pendiente',
          ),
        ),
      );
      if (widget.expense == null) ref.read(ocrProvider.notifier).reset();
      final updated = await repository.getExpense(
        expense.id,
        expense.accountScope,
      );
      if (!mounted) return;
      context.pop(widget.expense == null ? null : updated ?? expense);
    } on CustomError catch (error) {
      if (mounted) setState(() => _saveError = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _saveError = 'No se pudo guardar el gasto localmente.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showFullScreenImage(String imagePath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expense == null) {
      ref.listen(ocrProvider, (previous, next) {
        if (previous?.isLoading == true && next.isLoading == false) {
          if (next.result != null) {
            final result = next.result!;
            _rucController.text = result.ruc;
            _businessNameController.text = result.businessName;
            _typeController.text = result.type;
            _dateController.text = result.date;
            _serialController.text = result.serialNumber;
            _subtotalController.text = result.subtotal > 0
                ? result.subtotal.toStringAsFixed(2)
                : '';
            _igvController.text = result.igv > 0
                ? result.igv.toStringAsFixed(2)
                : '0.00';
            _totalController.text = result.total > 0
                ? result.total.toStringAsFixed(2)
                : '';
          }
        }
      });
    }

    final ocrState = ref.watch(ocrProvider);
    final taxSettings = ref.watch(taxSettingsProvider);
    final productsState = ref.watch(expenseProductsProvider);
    final taxTreatment =
        widget.expense?.taxTreatment ??
        ocrState.result?.taxTreatment ??
        ExpenseTaxTreatment.unknown;
    final effectiveTaxName = widget.expense?.taxName ?? taxSettings.taxName;
    final effectiveTaxRate =
        widget.expense?.taxRatePercentage ?? taxSettings.ratePercentage;
    final previewImagePath = widget.expense == null
        ? ocrState.imagePath
        : _editImagePath;
    final usesTotalAsAnchor = taxTreatment != ExpenseTaxTreatment.mixed;

    if (widget.expense == null && ocrState.isLoading) {
      return Scaffold(
        backgroundColor: paperColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: mainColor),
              const SizedBox(height: 24),
              const Text(
                'Leyendo comprobante',
                style: TextStyle(
                  color: inkColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Buscando RUC, serie, subtotal, IGV y total...',
                style: TextStyle(color: mutedInkColor),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.expense == null && ocrState.isBlocked) {
      return _buildBlockedState(ocrState.error);
    }

    return Scaffold(
      backgroundColor: paperColor,
      appBar: AppBar(
        title: Text(
          widget.expense == null ? 'Registrar gasto' : 'Editar gasto',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.expense == null && ocrState.error != null)
                _buildNotice(
                  message: ocrState.error!,
                  color: dangerColor,
                  icon: Icons.error_outline,
                ),

              if (widget.expense == null && ocrState.warnings.isNotEmpty)
                _buildNotice(
                  message: ocrState.warnings.join('\n'),
                  color: warningColor,
                  icon: Icons.warning_amber_rounded,
                ),

              if (previewImagePath != null)
                GestureDetector(
                  onTap: () => _showFullScreenImage(previewImagePath),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    height: 204,
                    decoration: BoxDecoration(
                      color: inkColor,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: lineColor),
                      image: DecorationImage(
                        image: FileImage(File(previewImagePath)),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: inkColor.withValues(alpha: 0.10),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: inkColor.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

              _buildSection(
                title: 'Comercio',
                children: [
                  _buildTextField(controller: _rucController, label: 'RUC'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _businessNameController,
                    label: 'Razón Social',
                  ),
                  const SizedBox(height: 16),
                  _buildProductSelector(productsState),
                ],
              ),
              const SizedBox(height: 20),

              _buildSection(
                title: 'Comprobante',
                children: [
                  _buildTextField(
                    controller: _typeController,
                    label: 'Tipo (Factura, Boleta...)',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _serialController,
                    label: 'Serie y Número',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _dateController, label: 'Fecha'),
                ],
              ),
              const SizedBox(height: 20),

              _buildSection(
                title: 'Montos',
                children: [
                  if (_saveError != null)
                    _buildNotice(
                      message: _saveError!,
                      color: dangerColor,
                      icon: Icons.save_outlined,
                    ),
                  Text(
                    effectiveTaxName == null
                        ? 'Cálculo automático con IGV ${effectiveTaxRate.toStringAsFixed(2)}%.'
                        : 'Cálculo automático con $effectiveTaxName '
                              '(${effectiveTaxRate.toStringAsFixed(2)}%).',
                    style: const TextStyle(
                      color: mutedInkColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_amountsError != null)
                    _buildNotice(
                      message: _amountsError!,
                      color: dangerColor,
                      icon: Icons.error_outline,
                    ),
                  if (_amountsError != null) const SizedBox(height: 16),
                  _buildTextField(
                    controller: _subtotalController,
                    label: 'Subtotal',
                    prefixText: 'S/ ',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    readOnly: usesTotalAsAnchor,
                    onChanged: (_) => _clearAmountsError(),
                    validator: (value) =>
                        _validateMoneyField(value, label: 'Subtotal'),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _igvController,
                    label: 'IGV',
                    prefixText: 'S/ ',
                    helperText:
                        'Se calcula desde el total; es 0.00 si es exonerado o inafecto.',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    readOnly: usesTotalAsAnchor,
                    onChanged: (_) => _clearAmountsError(),
                    validator: (value) => _validateMoneyField(
                      value,
                      label: 'IGV',
                      allowZero: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _totalController,
                    label: 'Total',
                    prefixText: 'S/ ',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    helperText: usesTotalAsAnchor
                        ? 'Monto principal para calcular subtotal e impuesto.'
                        : 'Operación mixta: revisa las bases e impuesto detectados.',
                    onChanged: (_) {
                      _clearAmountsError();
                      if (usesTotalAsAnchor) _syncAmountsFromTotal();
                    },
                    validator: (value) =>
                        _validateMoneyField(value, label: 'Total'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isSaving ? null : _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: inkColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      )
                    : Text(
                        widget.expense == null
                            ? 'Guardar gasto'
                            : 'Guardar cambios',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: inkColor.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: lineColor.withValues(alpha: 0.75)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: inkColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? prefixText,
    String? helperText,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          color: inkColor,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: mainColor),
        ),
        filled: true,
        fillColor: receiptColor,
      ),
    );
  }

  Widget _buildProductSelector(ExpenseProductsState state) {
    final products = [...state.products];
    if (_selectedProductId != null &&
        !products.any((product) => product.id == _selectedProductId)) {
      products.insert(
        0,
        ExpenseProduct(
          id: _selectedProductId!,
          name: _selectedProductName ?? 'Categoría seleccionada',
        ),
      );
    }
    final selectedValue =
        products.any((product) => product.id == _selectedProductId)
        ? _selectedProductId
        : null;

    return DropdownButtonFormField<int>(
      initialValue: selectedValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Categoría',
        helperText: state.isLoading && products.isEmpty
            ? 'Cargando categorías desde Odoo...'
            : state.errorMessage.isNotEmpty
            ? state.errorMessage
            : 'Categoría de gasto de Odoo (product.product).',
        helperMaxLines: 3,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: mainColor),
        ),
        filled: true,
        fillColor: receiptColor,
      ),
      hint: const Text('Selecciona una categoría'),
      items: products
          .map(
            (product) => DropdownMenuItem<int>(
              value: product.id,
              child: Text(product.displayName, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: products.isEmpty
          ? null
          : (productId) {
              if (productId == null) return;
              final product = products.firstWhere(
                (item) => item.id == productId,
              );
              setState(() {
                _selectedProductId = product.id;
                _selectedProductName = product.name;
                _saveError = null;
              });
            },
      validator: (value) =>
          value == null ? 'Selecciona una categoría de gasto.' : null,
    );
  }

  String? _validateMoneyField(
    String? value, {
    required String label,
    bool allowZero = false,
  }) {
    if (value == null || value.trim().isEmpty) return 'Ingresa $label.';

    final amount = MoneyUtils.parse(value);
    if (amount == null) return 'Ingresa un monto válido para $label.';
    if (amount < 0) return '$label no puede ser negativo.';
    if (!allowZero && amount == 0) return '$label debe ser mayor que cero.';

    return null;
  }

  void _clearAmountsError() {
    if (_amountsError != null) setState(() => _amountsError = null);
  }

  void _syncAmountsFromTotal() {
    final total = MoneyUtils.parse(_totalController.text);
    final treatment =
        widget.expense?.taxTreatment ??
        ref.read(ocrProvider).result?.taxTreatment ??
        ExpenseTaxTreatment.unknown;
    final isTaxFree =
        treatment == ExpenseTaxTreatment.exempt ||
        treatment == ExpenseTaxTreatment.unaffected;
    final ratePercentage = isTaxFree
        ? 0.0
        : widget.expense?.taxRatePercentage ??
              ref.read(taxSettingsProvider).ratePercentage;
    final amounts = ExpenseAmountSync.from(
      anchorValue: total,
      anchor: ExpenseAnchor.total,
      ratePercentage: ratePercentage,
    );

    _subtotalController.text = amounts?.subtotal.toStringAsFixed(2) ?? '';
    _igvController.text = amounts?.igv.toStringAsFixed(2) ?? '';
  }

  Widget _buildNotice({
    required String message,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedState(String? error) {
    return Scaffold(
      backgroundColor: paperColor,
      appBar: AppBar(
        title: Text(
          widget.expense == null ? 'Registrar gasto' : 'Editar gasto',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: dangerColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: dangerColor,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No se puede registrar este comprobante',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: inkColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                error ?? 'No se pudo identificar un gasto en la imagen.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: mutedInkColor, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(ocrProvider.notifier).reset();
                    context.pop();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Elegir otra imagen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: inkColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
