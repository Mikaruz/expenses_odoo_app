import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/domain/entities/ocr_expense_result.dart';
import 'package:oh_expenses_app/features/expenses/presentation/providers/ocr_provider.dart';
import 'package:oh_expenses_app/features/expenses/utils/expense_amount_validator.dart';
import 'package:oh_expenses_app/features/expenses/utils/money_utils.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key});

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
  String? _amountsError;

  @override
  void initState() {
    super.initState();
    final ocrState = ref.read(ocrProvider);
    final result = ocrState.result;

    _rucController = TextEditingController(text: result?.ruc ?? '');
    _businessNameController = TextEditingController(
      text: result?.businessName ?? '',
    );
    _typeController = TextEditingController(text: result?.type ?? '');
    _dateController = TextEditingController(text: result?.date ?? '');
    _serialController = TextEditingController(text: result?.serialNumber ?? '');
    _subtotalController = TextEditingController(
      text: (result?.subtotal ?? 0) > 0
          ? result!.subtotal.toStringAsFixed(2)
          : '',
    );
    _igvController = TextEditingController(
      text: result == null ? '' : result.igv.toStringAsFixed(2),
    );
    _totalController = TextEditingController(
      text: (result?.total ?? 0) > 0 ? result!.total.toStringAsFixed(2) : '',
    );
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

  void _saveExpense() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final result = ref.read(ocrProvider).result;
    final validation = ExpenseAmountValidator.validate(
      subtotal: MoneyUtils.parse(_subtotalController.text),
      igv: MoneyUtils.parse(_igvController.text),
      total: MoneyUtils.parse(_totalController.text),
      taxTreatment: result?.taxTreatment ?? ExpenseTaxTreatment.unknown,
    );

    if (!validation.isValid) {
      setState(() => _amountsError = validation.errorMessage);
      return;
    }

    setState(() => _amountsError = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gasto guardado exitosamente')),
    );
    ref.read(ocrProvider.notifier).reset();
    context.pop(); // Go back to home
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

    final ocrState = ref.watch(ocrProvider);

    if (ocrState.isLoading) {
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

    if (ocrState.isBlocked) {
      return _buildBlockedState(ocrState.error);
    }

    return Scaffold(
      backgroundColor: paperColor,
      appBar: AppBar(title: const Text('Registrar gasto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (ocrState.error != null)
                _buildNotice(
                  message: ocrState.error!,
                  color: dangerColor,
                  icon: Icons.error_outline,
                ),

              if (ocrState.warnings.isNotEmpty)
                _buildNotice(
                  message: ocrState.warnings.join('\n'),
                  color: warningColor,
                  icon: Icons.warning_amber_rounded,
                ),

              if (ocrState.imagePath != null)
                GestureDetector(
                  onTap: () => _showFullScreenImage(ocrState.imagePath!),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    height: 204,
                    decoration: BoxDecoration(
                      color: inkColor,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: lineColor),
                      image: DecorationImage(
                        image: FileImage(File(ocrState.imagePath!)),
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
                  _buildTextField(
                    controller: _rucController,
                    label: 'RUC',
                    icon: Icons.business,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _businessNameController,
                    label: 'Razón Social',
                    icon: Icons.storefront,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildSection(
                title: 'Comprobante',
                children: [
                  _buildTextField(
                    controller: _typeController,
                    label: 'Tipo (Factura, Boleta...)',
                    icon: Icons.receipt_long,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _serialController,
                    label: 'Serie y Número',
                    icon: Icons.numbers,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _dateController,
                    label: 'Fecha',
                    icon: Icons.calendar_today,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildSection(
                title: 'Montos',
                children: [
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
                    icon: Icons.calculate_outlined,
                    prefixText: 'S/ ',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _clearAmountsError(),
                    validator: (value) =>
                        _validateMoneyField(value, label: 'Subtotal'),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _igvController,
                    label: 'IGV',
                    icon: Icons.account_balance_wallet_outlined,
                    prefixText: 'S/ ',
                    helperText:
                        'Usualmente 18%; usa 0.00 si es exonerado o inafecto.',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                    icon: Icons.monetization_on_outlined,
                    prefixText: 'S/ ',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _clearAmountsError(),
                    validator: (value) =>
                        _validateMoneyField(value, label: 'Total'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: inkColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Guardar gasto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? prefixText,
    String? helperText,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon, color: mutedInkColor),
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
      appBar: AppBar(title: const Text('Registrar gasto')),
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
