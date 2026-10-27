import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/price_helper.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/diamond.dart';

class WhatsAppShareDialog extends StatelessWidget {
  final List<Diamond> diamonds;

  const WhatsAppShareDialog({super.key, required this.diamonds});

  void _shareViaWhatsApp(BuildContext context, {required bool withPrice}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final buffer = StringBuffer();

    for (int i = 0; i < diamonds.length; i++) {
      final d = diamonds[i];
      final priceInfo = PriceHelper.getDiamondPrice(d, auth);

      final img = d.imageUrl.isNotEmpty
          ? d.imageUrl
          : (d.imageArray.isNotEmpty ? d.imageArray.first : '');
      final vid = d.videoUrl.isNotEmpty
          ? d.videoUrl
          : (d.videoArray.isNotEmpty ? d.videoArray.first : '');
      final cert = d.certUrl.isNotEmpty
          ? d.certUrl
          : (d.certificateArray.isNotEmpty ? d.certificateArray.first : '');

      buffer.writeln('Stock No: ${d.serialNo}');
      buffer.writeln('Shape: ${d.shape.toUpperCase()}');
      buffer.writeln('Color: ${d.color.toUpperCase()}');
      buffer.writeln('Clarity: ${d.grade.toUpperCase()}');
      buffer.writeln('Carat: ${d.weight.toStringAsFixed(2)} Carat');

      if (withPrice) {
        if (priceInfo.isHidden) {
          buffer.writeln('Price: Price Upon Request');
        } else if (priceInfo.totalPrice > 0) {
          final formattedPerCt = priceInfo.formattedPerCt.replaceAll('\$', '\$ ');
          final formattedTotal = priceInfo.formattedTotal.replaceAll('\$', '\$ ');
          buffer.writeln('Price Per Carat: $formattedPerCt / Carat');
          buffer.writeln('Total: $formattedTotal');
        }
      }

      if (d.location.isNotEmpty) {
        buffer.writeln('Location: ${d.location}');
      }
      if (img.isNotEmpty) {
        buffer.writeln('Image: $img');
      }
      if (vid.isNotEmpty) {
        buffer.writeln('Video: $vid');
      }
      if (cert.isNotEmpty) {
        buffer.writeln('Certificate: $cert');
      }

      buffer.writeln('--------------------');
    }

    final text = buffer.toString();
    await WhatsAppHelper.launchWhatsApp(context, text);

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.whatsapp, size: 22),
          SizedBox(width: 8),
          Text('Share to WhatsApp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Text(
        'Share ${diamonds.length} selected diamond(s) via WhatsApp. Choose whether to include the retail price.',
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => _shareViaWhatsApp(context, withPrice: false),
          child: const Text('Without Price'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.whatsapp),
          onPressed: () => _shareViaWhatsApp(context, withPrice: true),
          child: const Text('With Price'),
        ),
      ],
    );
  }
}
