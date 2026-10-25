import 'package:oh_expenses_app/features/config/domain/domain.dart';
import 'package:oh_expenses_app/features/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ocr_scan_mode_provider.g.dart';

@Riverpod(keepAlive: true)
class OcrScanModeNotifier extends _$OcrScanModeNotifier {
  static const _storageKey = 'ocrScanMode';

  late final KeyValueStorageService _storage;
  var _loaded = false;

  @override
  OcrScanMode build() {
    _storage = KeyValueStorageServiceImpl();
    return OcrScanMode.automatic;
  }

  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;

    final storedValue = await _storage.getValue<String>(_storageKey);
    if (!ref.mounted) return;
    state = OcrScanMode.fromStorage(storedValue);
    _loaded = true;
  }

  Future<void> setMode(OcrScanMode mode) async {
    state = mode;
    _loaded = true;
    await _storage.setKeyValue(_storageKey, mode.storageValue);
  }
}
