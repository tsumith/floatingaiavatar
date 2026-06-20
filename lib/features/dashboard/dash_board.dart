import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pupz/core/config/app_config.dart';
import 'package:pupz/features/auth/bloc/auth_bloc.dart';
import 'package:pupz/features/auth/bloc/auth_event.dart';
import 'package:pupz/features/overlay/overlay_service.dart';
import 'package:pupz/features/tts/tts_service.dart';

/// ------------------------------------------------------------
/// Dashboard
/// Primary landing screen
/// ------------------------------------------------------------
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TTSService _ttsService = TTSService.instance;

  /// ------------------------------------------------------------
  /// Actions
  /// ------------------------------------------------------------
  Future<void> _handleLogout(BuildContext context) async {
    await OverlayService.shareData('close_overlay');
    await OverlayService.dismissOverlay();

    if (!context.mounted) return;
    context.read<AuthBloc>().add(AuthSignOutRequested());
  }

  Future<void> _summonOverlay(BuildContext context) async {
    await OverlayService.summonOverlay();

    if (!mounted) return;

    final isRunning = await OverlayService.isOverlayRunning();
    _showSnackBar(
      context,
      isRunning ? 'Floating buddy activated' : 'Overlay permission not granted',
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pupz Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your floating AI companion',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              /// Summon Overlay
              ElevatedButton.icon(
                onPressed: () => _summonOverlay(context),
                icon: const Icon(Icons.pets),
                label: const Text(
                  'Summon Floating Buddy',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// Dismiss Overlay
              TextButton(
                onPressed: OverlayService.dismissOverlay,
                child: const Text(
                  'Dismiss Buddy',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              /// Remote Config Test
              TextButton(
                onPressed: () {
                  _showSnackBar(context, AppConfig().welcomeMessage);
                },
                child: const Text('Check remote configuration'),
              ),

              /// TTS Test
              TextButton(
                onPressed: () {
                  _ttsService.speak('Hello! I am your floating assistant.');
                },
                child: const Text('Test text to speech'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
