import 'package:flutter/foundation.dart';

import 'package:pupz/features/action_router/models/intent_response.dart';
import 'feature_module.dart';

/// ------------------------------------------------------------
/// Intent Router
/// Routes resolved intents to registered feature modules
/// ------------------------------------------------------------
class IntentRouter {
  /// Registry of active feature modules keyed by intent type
  final Map<String, FeatureModule> _modules = {};

  /// Registers a feature module during application startup
  void registerModule(FeatureModule module) {
    _modules[module.moduleType] = module;
  }

  /// Dispatches an intent to the appropriate feature module
  ///
  /// Returns `true` if the intent was handled successfully
  Future<bool> dispatch(IntentResponse intent) async {
    final String? intentType = intent.type;
    if (intentType == null) return false;

    final FeatureModule? module = _modules[intentType];
    if (module == null) {
      debugPrint(
        '[IntentRouter] No module registered for intent: $intentType',
      );
      return false;
    }

    try {
      return await module.execute(intent.parameters);
    } catch (error) {
      debugPrint(
        '[IntentRouter] Failed to execute module "$intentType": $error',
      );
      return false;
    }
  }
}