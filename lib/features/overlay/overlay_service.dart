import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart'
    hide PermissionStatus;

/// ------------------------------------------------------------
/// Overlay Service
/// Handles permission checks and overlay lifecycle
/// ------------------------------------------------------------
class OverlayService {
  static const String _overlayTitle = 'Pupz Buddy';
  static const String _overlayContent = 'Your buddy is active';

  /// Returns whether the overlay is currently active
  static Future<bool> isOverlayRunning() async {
    return FlutterOverlayWindow.isActive();
  }

  /// Requests permissions and launches the overlay
  static Future<void> summonOverlay() async {
    final permissionsGranted = await _requestRequiredPermissions();
    if (!permissionsGranted) return;

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      overlayTitle: _overlayTitle,
      overlayContent: _overlayContent,
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.none,
      height: 500,
      width: 500,
    );
  }

  /// Shares data with the active overlay isolate
  static Future<void> shareData(dynamic data) async {
    await FlutterOverlayWindow.shareData(data);
  }

  /// Closes the active overlay
  static Future<void> dismissOverlay() async {
    await FlutterOverlayWindow.closeOverlay();
  }

  /// ------------------------------------------------------------
  /// Permissions
  /// ------------------------------------------------------------
  static Future<bool> _requestRequiredPermissions() async {
    if (!await _requestMicrophonePermission()) return false;
    if (!await _requestOverlayPermission()) return false;

    // Contact permission for calls
    await _requestContactsPermission();

    return true;
  }

  static Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      debugPrint('[Overlay] Microphone permission denied');
      return false;
    }
    return true;
  }

  static Future<bool> _requestOverlayPermission() async {
    var granted = await FlutterOverlayWindow.isPermissionGranted();
    if (granted) return true;

    await FlutterOverlayWindow.requestPermission();
    granted = await FlutterOverlayWindow.isPermissionGranted();

    if (!granted) {
      debugPrint('[Overlay] Overlay permission denied');
    }

    return granted;
  }

  static Future<void> _requestContactsPermission() async {
    try {
      final status = await FlutterContacts.permissions.request(
        PermissionType.read,
      );

      if (status != PermissionStatus.granted) {
        debugPrint(
          '[Overlay] Contacts permission denied — optional feature disabled',
        );
      }
    } catch (error) {
      debugPrint('[Overlay] Contacts permission error: $error');
    }
  }
}
