import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/recaptcha_box.dart';
import '../../domain/entities/diamond.dart';

class EmailDiamondDialog extends StatefulWidget {
  final Diamond diamond;

  const EmailDiamondDialog({super.key, required this.diamond});

  @override
  State<EmailDiamondDialog> createState() => _EmailDiamondDialogState();
}

class _EmailDiamondDialogState extends State<EmailDiamondDialog> {
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _markupController = TextEditingController();
  bool _isSending = false;
  bool _isCaptchaChecked = false;

  @override
  void initState() {
    super.initState();
    _messageController.text =
        'Hello, I would like to inquire about this diamond: ${widget.diamond.shape} ${Formatters.formatCarat(widget.diamond.weight)} (${widget.diamond.color}, ${widget.diamond.grade}) - Item: ${widget.diamond.serialNo}.';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    _markupController.dispose();
    super.dispose();
  }

  void _sendEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid recipient email address')),
      );
      return;
    }

    if (!_isCaptchaChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify that you are not a robot.'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() => _isSending = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Inquiry email for diamond #${widget.diamond.serialNo} sent successfully!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Email Diamond',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Recipient Email
              const Text('Recipient Email *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'client@example.com',
                  prefixIcon: Icon(Icons.email_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 12),

              // Message
              const Text('Message *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              TextField(
                controller: _messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add custom notes or instructions...',
                ),
              ),
              const SizedBox(height: 12),

              // Markup %
              const Text('Markup % (Optional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              TextField(
                controller: _markupController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'e.g. 15',
                  suffixText: '%',
                ),
              ),
              const SizedBox(height: 16),

              // reCAPTCHA Box
              Center(
                child: RecaptchaBox(
                  value: _isCaptchaChecked,
                  onChanged: (val) => setState(() => _isCaptchaChecked = val),
                ),
              ),
              const SizedBox(height: 16),

              // Send Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _sendEmail,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send, size: 18),
                  label: Text(_isSending ? 'Sending...' : 'Send Inquiry'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
