import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

import 'package:pupz/features/avatar/avatar_provider.dart';
import 'package:pupz/features/avatar/avatar_status.dart';

/// ------------------------------------------------------------
/// Avatar Widget
/// Floating animated AI avatar rendered via Rive
/// ------------------------------------------------------------
class AvatarWidget extends StatefulWidget {
  const AvatarWidget({super.key});

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  late final FileLoader _fileLoader;

  @override
  void initState() {
    super.initState();
    _fileLoader = FileLoader.fromAsset(
      'assets/animations/floatingaiavatar.riv',
      riveFactory: Factory.rive,
    );
  }

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = context.watch<AvatarProvider>();

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Avatar Interaction
          GestureDetector(
            onTap: context.read<AvatarProvider>().toggleMic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 150,
              width: 150,
              color: Colors.transparent,
              child: _buildRiveAvatar(avatar),
            ),
          ),

          const SizedBox(height: 6),

          /// Avatar Message Bubble
          _AvatarMessageBubble(message: avatar.message),
        ],
      ),
    );
  }

  /// ------------------------------------------------------------
  /// Rive Avatar Renderer
  /// ------------------------------------------------------------
  Widget _buildRiveAvatar(AvatarProvider avatar) {
    return RiveWidgetBuilder(
      fileLoader: _fileLoader,
      stateMachineSelector: const StateMachineNamed('floating_ai'),
      dataBind: DataBind.auto(),
      builder: (context, state) {
        if (state is RiveLoaded) {
          _syncAvatarState(state, avatar);
          return RiveWidget(
            controller: state.controller,
            fit: RiveDefaults.fit,
          );
        }

        if (state is RiveLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return const Icon(Icons.error, color: Colors.red);
      },
    );
  }

  /// ------------------------------------------------------------
  /// State Sync
  /// ------------------------------------------------------------
  void _syncAvatarState(RiveLoaded state, AvatarProvider avatar) {
    final rootVM = state.viewModelInstance;
    if (rootVM == null) return;

    final headVM = rootVM.viewModel('head');
    final faceVM = headVM?.viewModel('face');
    if (faceVM == null) return;

    faceVM.boolean('eyeListening')?.value =
        avatar.status == AvatarStatus.listening ||
        avatar.status == AvatarStatus.hearing;

    faceVM.boolean('eyesLoading')?.value =
        avatar.status == AvatarStatus.thinking;

    faceVM.boolean('eyesSpeaking')?.value =
        avatar.status == AvatarStatus.speaking;
  }
}

/// ------------------------------------------------------------
/// Avatar Message Bubble
/// ------------------------------------------------------------
class _AvatarMessageBubble extends StatelessWidget {
  final String message;

  const _AvatarMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}