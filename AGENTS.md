# AGENTS.md

## Contexto del Proyecto

Este proyecto es una app Flutter/Dart llamada `oh_expenses_app` para registrar gastos relacionados con Odoo.

Tecnologías principales:
- Flutter y Dart.
- Riverpod con `riverpod_annotation` y archivos generados `*.g.dart`.
- GoRouter para navegación.
- Dio para llamadas HTTP.
- Formz para validación de formularios.
- Google ML Kit Text Recognition para OCR.
- Image Picker para cámara/galería.
- Shared Preferences para almacenamiento local simple.

Estructura principal:
- `lib/main.dart`: punto de entrada.
- `lib/config`: router, tema, utilidades y HTTP.
- `lib/features/auth`: autenticación, login y recuperación de contraseña.
- `lib/features/expenses`: OCR, parser y registro de gastos.
- `lib/features/home`: dashboard, perfil y listado de gastos.
- `lib/features/shared`: inputs, errores, servicios y widgets compartidos.

## Reglas Generales

- Mantener cambios pequeños, directos y consistentes con la arquitectura existente.
- No editar manualmente archivos generados `*.g.dart`.
- Si se modifican providers anotados con Riverpod, ejecutar generación con `dart run build_runner build --delete-conflicting-outputs`.
- Preservar la estructura por features antes de crear nuevas carpetas o abstracciones.
- Preferir modificar providers, repositories, datasources, mappers y widgets existentes antes de añadir nuevas capas.
- No introducir secretos, credenciales, tokens, nombres de base de datos productivos ni URLs privadas hardcodeadas.
- No guardar contraseñas en `shared_preferences` salvo que se acepte explícitamente ese riesgo.
- Usar mensajes de error claros mediante `CustomError` cuando aplique.

## Flutter y UI

- Seguir patrones actuales de Flutter, Riverpod y GoRouter.
- Usar `context.mounted` después de operaciones async antes de interactuar con UI.
- Mantener el diseño visual existente salvo que la tarea pida rediseño.
- Revisar permisos de Android/iOS al tocar cámara, galería, archivos u OCR.
- Evitar datos mock en funcionalidades finales; si se mantienen, deben estar claramente limitados a prototipo.

## Odoo e Integración API

- Las llamadas Odoo deben seguir la separación `domain` -> `infrastructure` -> `presentation`.
- No inventar endpoints. Si falta contrato de API, pedirlo o documentar el contrato esperado.
- Tratar `session_id`, cookies y datos de sesión como información sensible.
- Validar respuestas malformadas, credenciales inválidas, timeouts y errores HTTP.
- Evitar nombres de base de datos hardcodeados en código de producción.

## OCR y Parser de Gastos

- El parser principal está en `lib/features/expenses/utils/ocr_parser.dart`.
- Los cambios al parser deben ser determinísticos y testeables.
- Priorizar pruebas unitarias para `OcrParser.parse`.
- Considerar casos de comprobantes peruanos: RUC, IGV, boleta, factura, ticket, serie, total, exonerada e inafecta.
- No inventar IGV o total cuando el texto OCR no lo respalda claramente.
- Cerrar correctamente recursos de ML Kit.

## Testing y Verificación

- Ejecutar `flutter analyze` después de cambios de código.
- Ejecutar `flutter test` si se agregan o modifican tests.
- Actualmente `test/widget_test.dart` está comentado y `flutter test` falla por no tener `main`.
- Al tocar parser OCR, agregar casos de prueba con texto OCR representativo.
- Al tocar auth/routing, verificar acceso no autenticado, logout, redirects y loops.

## Revisión de Código

Al revisar cambios, priorizar:
- Bugs funcionales.
- Regresiones de auth o navegación.
- Manejo inseguro de sesión o credenciales.
- Errores de parser OCR y casos límite.
- Falta de tests.
- Problemas de permisos móviles.
- Configuración pendiente para producción.
