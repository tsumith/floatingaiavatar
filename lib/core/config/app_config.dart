import 'package:firebase_remote_config/firebase_remote_config.dart';

/// ------------------------------------------------------------
/// AppConfig 
/// ------------------------------------------------------------
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  late final Uri _gatewayUri;
  late final bool _maintenanceMode;
  late final String _welcomeMessage;

  bool _initialized = false;

  Future<void> init({required bool isOverlay}) async {
    if (_initialized) return;
    _initialized = true;

    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      const RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 30),
        minimumFetchInterval: Duration(hours: 1),
      ),
    );

    await remoteConfig.setDefaults(const {
      'gateway_url': 'https://api.example.com',
      'maintenance_mode': false,
      'welcome_message': 'Welcome.',
    });

    try {
      await remoteConfig.fetchAndActivate();
    } catch (_) {}

    _gatewayUri = Uri.parse(remoteConfig.getString('gateway_url'));
    _maintenanceMode = remoteConfig.getBool('maintenance_mode');
    _welcomeMessage = remoteConfig.getString('welcome_message');
  }

  Uri get gatewayUri => _gatewayUri;
  bool get maintenanceMode => _maintenanceMode;
  String get welcomeMessage => _welcomeMessage;
}