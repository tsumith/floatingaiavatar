import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../feature_module.dart';

/// ------------------------------------------------------------
/// WhatsApp Feature Module
/// Sends a message via WhatsApp, optionally targeting a contact
/// ------------------------------------------------------------
class WhatsAppModule implements FeatureModule {
  @override
  String get moduleType => 'WHATSAPP_ACTION';

  @override
  Future<bool> execute(Map<String, dynamic> payload) async {
    final String message = payload['message']?.toString() ?? '';
    final String targetName =
        payload['contact_name']?.toString().toLowerCase() ?? '';

    if (message.isEmpty) return false;

    final String? phoneNumber = targetName.isNotEmpty
        ? await _resolveContact(targetName)
        : null;

    final Uri whatsappUri = _buildWhatsAppUri(
      message: message,
      phoneNumber: phoneNumber,
    );

    return _launchWhatsApp(whatsappUri);
  }

  /// ------------------------------------------------------------
  /// Contact Resolution
  /// ------------------------------------------------------------
  Future<String?> _resolveContact(String targetName) async {
    final permission = await FlutterContacts.permissions.request(
      PermissionType.read,
    );

    if (permission != PermissionStatus.granted) {
      debugPrint('[WhatsAppModule] Contact permission not granted');
      return null;
    }

    final contacts = await FlutterContacts.getAll(
      properties: {ContactProperty.phone},
    );

    for (final contact in contacts) {
      final name = contact.displayName?.toLowerCase() ?? '';
      if (name.contains(targetName) && contact.phones.isNotEmpty) {
        return _normalizePhoneNumber(contact.phones.first.number);
      }
    }

    return null;
  }

  /// ------------------------------------------------------------
  /// Launch Handling
  /// ------------------------------------------------------------
  Future<bool> _launchWhatsApp(Uri uri) async {
    try {
      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: uri.toString(),
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
        return true;
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }

      debugPrint('[WhatsAppModule] WhatsApp not available');
      return false;
    } catch (error) {
      debugPrint('[WhatsAppModule] Launch failed: $error');
      return false;
    }
  }

  /// ------------------------------------------------------------
  /// Utilities
  /// ------------------------------------------------------------
  Uri _buildWhatsAppUri({required String message, String? phoneNumber}) {
    final encodedMessage = Uri.encodeComponent(message);

    if (phoneNumber != null) {
      return Uri.parse(
        'whatsapp://send?phone=$phoneNumber&text=$encodedMessage',
      );
    }

    return Uri.parse('whatsapp://send?text=$encodedMessage');
  }

  String _normalizePhoneNumber(String rawNumber) {
    var cleaned = rawNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (!cleaned.startsWith('+')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^0'), '');
      cleaned = '+91$cleaned'; // Default country code (documented)
    }

    return cleaned.replaceAll('+', '');
  }
}
