import 'package:flutter/foundation.dart';
import 'package:pupz/features/overlay/overlay_service.dart';

import '../feature_module.dart';

/// ------------------------------------------------------------
/// Overlay Feature Module
/// Controls the floating avatar overlay lifecycle
/// ------------------------------------------------------------
class OverlayModule implements FeatureModule {
  @override
  String get moduleType => 'OVERLAY_ACTION';

  static const Set<String> _dismissCommands = {
    'dismiss',
    'close',
    'sleep',
    'turn off',
    'off',
  };

  @override
  Future<bool> execute(Map<String, dynamic> payload) async {
    final String? command = payload['command']?.toString();

    if (command == null) {
      debugPrint('[OverlayModule] No command provided');
      return false;
    }

    try {
      if (_dismissCommands.contains(command)) {
        await OverlayService.dismissOverlay();
        return true;
      }

      debugPrint('[OverlayModule] Unsupported command: $command');
      return false;
    } catch (error) {
      debugPrint('[OverlayModule] Execution failed: $error');
      return false;
    }
  }
}
