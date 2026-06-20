import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pupz/core/config/bootstrap.dart';
import 'package:pupz/features/auth/bloc/auth_bloc.dart';
import 'package:pupz/features/auth/bloc/auth_event.dart';
import 'package:pupz/features/auth/data/auth_repository.dart';
import 'package:pupz/features/auth/presentation/auth_guard.dart';
import 'package:pupz/features/avatar/avatar_provider.dart';
import 'package:pupz/features/avatar/avatar_widget.dart';

/// ------------------------------------------------------------
/// Main App Entry Point
/// ------------------------------------------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Shared app-level initialization (Supabase, envs, services)
  await SharedBootstrap.init(isOverlay: false);

  runApp(
    RepositoryProvider<AuthRepository>(
      create: (_) => AuthRepository(supabase: Supabase.instance.client),
      child: BlocProvider<AuthBloc>(
        create: (context) =>
            AuthBloc(authRepository: context.read<AuthRepository>())
              ..add(AuthCheckRequested()),
        child: const PupzApp(),
      ),
    ),
  );
}

/// ------------------------------------------------------------
/// Root Application Widget
/// ------------------------------------------------------------
class PupzApp extends StatelessWidget {
  const PupzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pupz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const AuthGuard(),
    );
  }
}

/// ------------------------------------------------------------
/// Overlay Entry Point (Isolated Flutter Engine)
/// ------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  /// Minimal bootstrap for overlay context
  await SharedBootstrap.init(isOverlay: true);
  await RiveNative.init();

  /// Permission check (no UI blocking here)
  await _verifyMicrophonePermission();

  /// Overlay lifecycle listener
  FlutterOverlayWindow.overlayListener.listen(_handleOverlayEvents);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AvatarProvider(),
      child: const OverlayApp(),
    ),
  );
}

/// ------------------------------------------------------------
/// Overlay Root Widget
/// ------------------------------------------------------------
class OverlayApp extends StatelessWidget {
  const OverlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AvatarWidget(),
    );
  }
}

/// ------------------------------------------------------------
/// Helpers
/// ------------------------------------------------------------
Future<void> _verifyMicrophonePermission() async {
  final isGranted = await Permission.microphone.isGranted;

  if (!isGranted) {
    debugPrint('[Overlay] Microphone permission not granted');
  }
}

void _handleOverlayEvents(dynamic event) {
  if (event == 'close_overlay' || event == 'Destroy') {
    FlutterOverlayWindow.closeOverlay();
  }
}
