import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';

/// ------------------------------------------------------------
/// SharedBootstrap
/// ------------------------------------------------------------
class SharedBootstrap {
  static bool _initialized = false;

  static Future<void> init({required bool isOverlay}) async {
    WidgetsFlutterBinding.ensureInitialized();

    _configureGlobalErrorHandling(isOverlay);

    if (_initialized) return;
    _initialized = true;

    await _initializeFirebase();
    await _initializeAppConfig(isOverlay);
    await _initializeSupabase();
  }

  // ------------------------------------------------------------
  // Error handling 
  // ------------------------------------------------------------
  static void _configureGlobalErrorHandling(bool isOverlay) {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Forward to crash reporting service 
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      // Forward to crash reporting service 
      return true;
    };
  }

  // ------------------------------------------------------------
  // Firebase + App Check
  // ------------------------------------------------------------
  static Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();

    await FirebaseAppCheck.instance.activate(
      providerAndroid: AndroidPlayIntegrityProvider(),
      providerApple: AppleAppAttestProvider(),
    );
  }

  // ------------------------------------------------------------
  // Remote / runtime configuration
  // ------------------------------------------------------------
  static Future<void> _initializeAppConfig(bool isOverlay) async {
    await AppConfig().init(isOverlay: isOverlay);
  }

  // ------------------------------------------------------------
  // Supabase
  // ------------------------------------------------------------
  static Future<void> _initializeSupabase() async {
    await Supabase.initialize(
      url: AppConfig().supabaseUrl,
      anonKey: AppConfig().supabaseKey,
    );
  }
}