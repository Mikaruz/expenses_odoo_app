class OcrExpenseResult {
  final String ruc;
  final String businessName; // Razón Social
  final String type; // FACTURA, BOLETA, TICKET, RECIBO
  final String date;
  final String serialNumber; // F001-00012345
  final double igv;
  final double total;
  final String rawText;

  const OcrExpenseResult({
    required this.ruc,
    required this.businessName,
    required this.type,
    required this.date,
    required this.serialNumber,
    required this.igv,
    required this.total,
    required this.rawText,
  });
}
