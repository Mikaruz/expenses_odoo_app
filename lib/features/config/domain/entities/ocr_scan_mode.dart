enum OcrScanMode {
  automatic(
    'automatic',
    'Según conexión',
    'Usa Odoo cuando está disponible y el dispositivo cuando no hay conexión.',
  ),
  device(
    'device',
    'Dispositivo',
    'Procesa la imagen siempre con el OCR local del dispositivo.',
  ),
  odoo(
    'odoo',
    'Servidor Odoo',
    'Procesa la imagen siempre con el OCR del servidor Odoo.',
  );

  final String storageValue;
  final String label;
  final String description;

  const OcrScanMode(this.storageValue, this.label, this.description);

  static OcrScanMode fromStorage(String? value) {
    return values.firstWhere(
      (mode) => mode.storageValue == value,
      orElse: () => OcrScanMode.automatic,
    );
  }
}
