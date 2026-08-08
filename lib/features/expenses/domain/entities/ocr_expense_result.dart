enum ExpenseTaxTreatment { unknown, taxable, exempt, unaffected, mixed }

class OcrExpenseResult {
  final String ruc;
  final String businessName; // Razón Social
  final String type; // FACTURA, BOLETA, TICKET, RECIBO
  final String date;
  final String serialNumber; // F001-00012345
  final double subtotal;
  final double igv;
  final double total;
  final ExpenseTaxTreatment taxTreatment;
  final bool igvWasInferred;
  final bool subtotalWasInferred;
  final String rawText;
  final bool isRemote;
  final String? validationStatus;
  final List<String> validationMessages;

  const OcrExpenseResult({
    required this.ruc,
    required this.businessName,
    required this.type,
    required this.date,
    required this.serialNumber,
    this.subtotal = 0.0,
    required this.igv,
    required this.total,
    this.taxTreatment = ExpenseTaxTreatment.unknown,
    this.igvWasInferred = false,
    this.subtotalWasInferred = false,
    required this.rawText,
    this.isRemote = false,
    this.validationStatus,
    this.validationMessages = const [],
  });
}
