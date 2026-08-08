# expenses_odoo_app

Aplicacion Flutter para registrar gastos en Odoo.

## OCR de Odoo

Cuando existe una sesion activa y hay conectividad, la app envia la imagen al
OCR del modulo `expense_ocr` mediante:

```text
POST /expense_ocr/api/v1/session/documents
GET  /expense_ocr/api/v1/session/documents/<id>
```

La app usa la cookie `session_id` creada durante el login normal de Odoo. No se
guarda una API key de Odoo en el dispositivo. El usuario de Odoo debe tener el
grupo `Expense OCR User`, un empleado relacionado y acceso a la compania activa.

El comprobante se procesa en Odoo y la app mapea RUC, razon social, tipo
Factura/Boleta, serie, numero, fecha, subtotal, IGV y total.

Si no existe sesion, la app esta en modo offline o la conexion falla, utiliza
el OCR local de ML Kit. Los errores funcionales devueltos por Odoo no se
reemplazan silenciosamente con un resultado local.

## Desarrollo

```bash
flutter pub get
flutter analyze
flutter test
```
