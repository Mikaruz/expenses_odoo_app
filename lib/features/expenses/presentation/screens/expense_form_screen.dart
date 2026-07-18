import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/expenses/presentation/providers/ocr_provider.dart';

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
  late TextEditingController _igvController;
  late TextEditingController _totalController;

  @override
  void initState() {
    super.initState();
    final ocrState = ref.read(ocrProvider);
    final result = ocrState.result;

    _rucController = TextEditingController(text: result?.ruc ?? '');
    _businessNameController = TextEditingController(text: result?.businessName ?? '');
    _typeController = TextEditingController(text: result?.type ?? '');
    _dateController = TextEditingController(text: result?.date ?? '');
    _serialController = TextEditingController(text: result?.serialNumber ?? '');
    _igvController = TextEditingController(
      text: (result?.igv ?? 0) > 0 ? result!.igv.toStringAsFixed(2) : '',
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
    _igvController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save logic, maybe call another provider
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gasto guardado exitosamente')),
      );
      context.pop(); // Go back to home
    }
  }

  void _showFullScreenImage(String imagePath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
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
          _igvController.text = result.igv > 0 ? result.igv.toStringAsFixed(2) : '';
          _totalController.text = result.total > 0 ? result.total.toStringAsFixed(2) : '';
        }
      }
    });

    final ocrState = ref.watch(ocrProvider);
    
    if (ocrState.isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: mainColor),
              const SizedBox(height: 24),
              const Text(
                'Analizando comprobante...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Registrar Gasto'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (ocrState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 253, 237, 237),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    ocrState.error!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),

              if (ocrState.imagePath != null)
                GestureDetector(
                  onTap: () => _showFullScreenImage(ocrState.imagePath!),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      image: DecorationImage(
                        image: FileImage(File(ocrState.imagePath!)),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),

              _buildSection(
                title: 'Información del Comercio',
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
                title: 'Detalles del Comprobante',
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _igvController,
                          label: 'IGV',
                          icon: Icons.account_balance_wallet_outlined,
                          prefixText: 'S/ ',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _totalController,
                          label: 'Total',
                          icon: Icons.monetization_on_outlined,
                          prefixText: 'S/ ',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Requerido';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Guardar Gasto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          color: Colors.black87, 
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: mainColor),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
