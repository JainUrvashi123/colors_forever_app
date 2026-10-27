import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecaptchaBox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const RecaptchaBox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<RecaptchaBox> createState() => _RecaptchaBoxState();
}

class _RecaptchaBoxState extends State<RecaptchaBox> {
  bool _isVerifying = false;

  void _handleTap() async {
    if (widget.value) {
      widget.onChanged(false);
      return;
    }

    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() => _isVerifying = false);
      widget.onChanged(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isChecked = widget.value;

    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isChecked ? const Color(0xFF4CAF50) : const Color(0xFFD0D7DE),
          width: isChecked ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: _isVerifying ? null : _handleTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 26,
                        height: 26,
                        child: _isVerifying
                            ? const Padding(
                                padding: EdgeInsets.all(3),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Color(0xFF4A90E2),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: isChecked ? const Color(0xFF4CAF50) : Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: isChecked ? const Color(0xFF4CAF50) : const Color(0xFFC1C7D0),
                                    width: 2,
                                  ),
                                ),
                                child: isChecked
                                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                                    : null,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          "I'm not a robot",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF24292F),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 22,
                      color: Color(0xFF4A90E2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'reCAPTCHA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8C959F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
