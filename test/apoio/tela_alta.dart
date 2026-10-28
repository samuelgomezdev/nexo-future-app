import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tela alta para os formulários caberem sem rolar.
void usarTelaAlta() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.platformDispatcher.views.first.physicalSize = const Size(1080, 2400);
  binding.platformDispatcher.views.first.devicePixelRatio = 1;
}

void restaurarTela() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.platformDispatcher.views.first.resetPhysicalSize();
  binding.platformDispatcher.views.first.resetDevicePixelRatio();
}
