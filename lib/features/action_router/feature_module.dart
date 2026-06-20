/// ------------------------------------------------------------
/// Feature Module Contract
/// Defines an executable action triggered by an intent
/// ------------------------------------------------------------
abstract class FeatureModule {
  /// Unique intent identifier handled by this module
  String get moduleType;

  /// Executes the module with the provided intent payload
  ///
  /// Returns `true` if the action was handled successfully
  Future<bool> execute(Map<String, dynamic> payload);
}
