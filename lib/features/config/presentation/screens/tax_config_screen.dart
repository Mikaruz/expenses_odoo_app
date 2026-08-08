import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/config/config.dart';

class TaxConfigScreen extends ConsumerStatefulWidget {
  const TaxConfigScreen({super.key});

  @override
  ConsumerState<TaxConfigScreen> createState() => _TaxConfigScreenState();
}

class _TaxConfigScreenState extends ConsumerState<TaxConfigScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(taxSettingsProvider.notifier).load();
      await ref.read(taxesProvider.notifier).loadTaxes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taxesState = ref.watch(taxesProvider);
    final settings = ref.watch(taxSettingsProvider);

    return Scaffold(
      backgroundColor: paperColor,
      appBar: AppBar(title: const Text('Impuestos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(settings),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Impuestos',
                  style: TextStyle(
                    color: inkColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  onPressed: () => ref.read(taxesProvider.notifier).loadTaxes(),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualizar impuestos',
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTaxesState(taxesState, settings.taxId),
            if (taxesState.errorMessage.isNotEmpty)
              _buildNotice(taxesState.errorMessage),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(TaxSettingsState settings) {
    final hasOdooTax = settings.taxId != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: lineColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long,
            color: hasOdooTax ? successColor : warningColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasOdooTax
                  ? '${settings.taxName}: ${settings.ratePercentage.toStringAsFixed(2)}%. '
                        'El total será el monto principal para calcular subtotal e IGV.'
                  : 'Se usará IGV 18.00% para calcular subtotal e IGV. Selecciona '
                        'el impuesto equivalente de Odoo para asociarlo al gasto.',
              style: const TextStyle(color: inkColor, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxesState(TaxesState state, int? selectedId) {
    final isLoaded = state.hasLoaded && state.errorMessage.isEmpty;

    if (state.isLoading && state.taxes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(color: mainColor),
        ),
      );
    }

    if (state.taxes.isEmpty) {
      return _buildNotice(
        isLoaded
            ? 'No se encontraron impuestos de compra en Odoo.'
            : state.errorMessage.isEmpty
            ? 'Cargando impuestos...'
            : 'No se pudieron cargar los impuestos desde Odoo.',
      );
    }

    return Column(
      children: state.taxes.map((tax) {
        final isActive = tax.id == selectedId;
        final isSupported = tax.supportsAutomaticCalculation;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            tileColor: isActive
                ? mainColor.withValues(alpha: 0.06)
                : surfaceColor,
            selected: isActive,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isActive ? mainColor.withValues(alpha: 0.4) : lineColor,
              ),
            ),
            leading: Icon(
              isActive
                  ? Icons.check_circle
                  : isSupported
                  ? Icons.percent
                  : Icons.info_outline,
              color: isActive
                  ? mainColor
                  : isSupported
                  ? mutedInkColor
                  : warningColor,
            ),
            title: Text(tax.name),
            subtitle: isSupported
                ? null
                : const Text(
                    'Disponible en Odoo, no compatible con cálculo automático',
                    style: TextStyle(color: mutedInkColor, fontSize: 12),
                  ),
            titleTextStyle: TextStyle(
              color: isSupported ? inkColor : mutedInkColor,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            trailing: isSupported
                ? Text(
                    '${tax.ratePercentage.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      color: inkColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  )
                : Text(
                    _amountTypeLabel(tax.amountType),
                    style: const TextStyle(
                      color: mutedInkColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
            onTap: isSupported
                ? () async {
                    await ref.read(taxSettingsProvider.notifier).setTax(tax);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Impuesto seleccionado: ${tax.name}'),
                      ),
                    );
                  }
                : null,
          ),
        );
      }).toList(),
    );
  }

  String _amountTypeLabel(String amountType) {
    return switch (amountType) {
      'fixed' => 'Monto fijo',
      'group' => 'Grupo',
      'division' => 'División',
      _ => amountType,
    };
  }

  Widget _buildNotice(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: dangerColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dangerColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.error_outline, color: dangerColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: dangerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
