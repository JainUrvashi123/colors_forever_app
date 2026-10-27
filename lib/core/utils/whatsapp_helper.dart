import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  /// Default phone number for Colors Forever Concierge
  static const String defaultPhone = '';

  /// Primary launch method for WhatsApp inquiries across mobile & web platforms.
  static Future<void> launchWhatsApp(BuildContext context, String message, {String? phone}) async {
    final encodedMsg = Uri.encodeComponent(message);
    final targetPhone = phone ?? defaultPhone;

    final Uri primaryUri = targetPhone.isNotEmpty
        ? Uri.parse('https://api.whatsapp.com/send?phone=$targetPhone&text=$encodedMsg')
        : Uri.parse('https://api.whatsapp.com/send?text=$encodedMsg');

    final Uri fallbackUri = targetPhone.isNotEmpty
        ? Uri.parse('https://wa.me/$targetPhone?text=$encodedMsg')
        : Uri.parse('https://wa.me/?text=$encodedMsg');

    try {
      if (await canLaunchUrl(primaryUri)) {
        await launchUrl(primaryUri, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        return;
      }
      final launched = await launchUrl(primaryUri, mode: LaunchMode.externalApplication);
      if (launched) return;
    } catch (_) {
      // Fall through
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open WhatsApp. Please check if WhatsApp is installed.'),
        ),
      );
    }
  }
}
