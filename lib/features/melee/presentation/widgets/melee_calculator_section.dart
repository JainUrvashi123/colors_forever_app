import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../domain/models/melee_constants.dart';
import '../providers/melee_provider.dart';
import 'melee_cart_sheet.dart';
import '../../../../core/widgets/diamond_swatch_card.dart';
import '../../../../core/widgets/guest_guard.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
String _toTitleCase(String text) {
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    final upper = word.toUpperCase();
    if (upper == 'I' || upper == 'II' || upper == 'III' || upper == 'IV') {
      return upper;
    }
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

class MeleeCalculatorSection extends StatefulWidget {
  final MeleeProvider provider;

  const MeleeCalculatorSection({
    super.key,
    required this.provider,
  });

  @override
  State<MeleeCalculatorSection> createState() => _MeleeCalculatorSectionState();
}

class _MeleeCalculatorSectionState extends State<MeleeCalculatorSection> with WidgetsBindingObserver {
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _qtyFocusNode = FocusNode();
  final FocusNode _commentFocusNode = FocusNode();
  Timer? _qtyDebounceTimer;
  bool _wasKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _qtyController.text =
        widget.provider.hasQuantity ? widget.provider.quantity.toString() : '';
    _commentController.text = widget.provider.specialRequest;
    widget.provider.addListener(_onProviderUpdated);

    _qtyFocusNode.addListener(() {
      if (!_qtyFocusNode.hasFocus) {
        _submitQuantity();
      }
    });

    _commentFocusNode.addListener(() {
      if (!_commentFocusNode.hasFocus) {
        widget.provider.setSpecialRequest(_commentController.text);
      }
    });
  }

  void _submitQuantity() {
    _qtyDebounceTimer?.cancel();
    final trimmed = _qtyController.text.trim();
    final num = int.tryParse(trimmed);
    if (trimmed.isEmpty || num == null || num <= 0) {
      widget.provider.setQuantity(null);
    } else {
      widget.provider.setQuantity(num);
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;
    final isKeyboardOpen = View.of(context).viewInsets.bottom > 0;
    if (_wasKeyboardOpen && !isKeyboardOpen) {
      if (_qtyFocusNode.hasFocus) {
        _submitQuantity();
      }
    }
    _wasKeyboardOpen = isKeyboardOpen;
  }

  void _onProviderUpdated() {
    if (!_qtyFocusNode.hasFocus) {
      final expectedQty =
          widget.provider.hasQuantity ? widget.provider.quantity.toString() : '';
      if (_qtyController.text != expectedQty) {
        _qtyController.text = expectedQty;
      }
    }
    if (!_commentFocusNode.hasFocus) {
      if (_commentController.text != widget.provider.specialRequest) {
        _commentController.text = widget.provider.specialRequest;
      }
    }
  }

  @override
  void didUpdateWidget(covariant MeleeCalculatorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) {
      oldWidget.provider.removeListener(_onProviderUpdated);
      widget.provider.addListener(_onProviderUpdated);
    }
    _onProviderUpdated();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _qtyDebounceTimer?.cancel();
    widget.provider.removeListener(_onProviderUpdated);
    _qtyFocusNode.dispose();
    _commentFocusNode.dispose();
    _qtyController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _showPremiumSizeDialog(BuildContext context, String size) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.fromLTRB(24, 20, 20, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Red Title + Close 'x' button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '$size is a premium size.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE53935),
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => Navigator.of(dialogCtx).pop(),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF3F4F6),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Body text matching user screenshot
                Text(
                  'You have selected a premium size which will cost you more.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: const Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'If you use a size up or a size down, you can safe the premium size charge.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: const Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),

                // Centered "OK" pill button
                Center(
                  child: InkWell(
                    onTap: () => Navigator.of(dialogCtx).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF222222),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        'OK',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF222222),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /*
  void _showSizePickerBottomSheet(BuildContext context) {
    final provider = widget.provider;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.straighten_rounded, color: AppColors.richGold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Select Diamond Size (Sieve / MM)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: provider.availableSizes.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
                    itemBuilder: (context, index) {
                      final size = provider.availableSizes[index];
                      final isSelected = provider.selectedSize == size;
                      final isPremium = MeleeConstants.isPremiumSize(size);

                      return ListTile(
                        onTap: () {
                          Navigator.pop(ctx);
                          if (isSelected) {
                            provider.selectSize(null);
                          } else {
                            provider.selectSize(size);
                            if (isPremium) {
                              Future.delayed(const Duration(milliseconds: 120), () {
                                if (context.mounted) {
                                  _showPremiumSizeDialog(context, size);
                                }
                              });
                            }
                          }
                        },
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppColors.richGold : AppColors.background,
                            border: Border.all(
                              color: isSelected ? AppColors.richGold : AppColors.border,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.diamond_outlined,
                              size: 16,
                              color: isSelected ? Colors.white : AppColors.richGold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              size,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? AppColors.richGold : AppColors.textPrimary,
                              ),
                            ),
                            if (isPremium) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.amber.shade400),
                                ),
                                child: Text(
                                  'Premium Size',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppColors.richGold)
                            : const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  */


  Widget _buildDisplayBox({
    required String text,
    double? width,
    double height = 38,
    bool isReadOnlyBadge = false,
  }) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isReadOnlyBadge ? const Color(0xFFF7F8FA) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isReadOnlyBadge ? const Color(0xFFDCDFE6) : const Color(0xFFCCCCCC),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF222222),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildQuantityBox({
    double? width,
    double height = 38,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        controller: _qtyController,
        focusNode: _qtyFocusNode,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF222222),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1E6FBA), width: 1.5),
          ),
        ),
        onChanged: (val) {
          _qtyDebounceTimer?.cancel();
          _qtyDebounceTimer = Timer(const Duration(milliseconds: 1500), () {
            if (mounted) {
              _submitQuantity();
            }
          });
        },
        onEditingComplete: () {
          _submitQuantity();
          _qtyFocusNode.unfocus();
        },
        onTapOutside: (_) {
          _submitQuantity();
        },
        onSubmitted: (val) {
          _submitQuantity();
          _qtyFocusNode.unfocus();
        },
      ),
    );
  }

  Widget _buildResetFilterButton(MeleeProvider provider) {
    return ResetFilterButton(
      height: 42,
      onTap: () {
        _qtyController.clear();
        _commentController.clear();
        provider.resetFilter(preserveStoneType: true);
        setState(() {});
      },
    );
  }

  Widget _buildAddToCartButton(BuildContext context, MeleeProvider provider) {
    return AddToCartButton(
      height: 42,
      onTap: () {
        final auth = context.read<AuthProvider>();
        if (!auth.isAuthenticated) {
          GuestGuard.requireLogin(
            context,
            actionLabel: 'add melee items to your cart',
          );
          return;
        }
        final success = provider.addToCart();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added ${provider.selectedShade ?? ''} (${provider.selectedSize ?? ''}) to cart!',
              ),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'View Cart',
                textColor: Colors.white,
                onPressed: () => MeleeCartSheet.show(context, provider),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final shades = provider.currentShades;
    final hasValidQuantity =
        provider.hasQuantity && _qtyController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. SHADE SECTION (Shown if shades available)
          if (shades.isNotEmpty) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'SHADE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    if (provider.selectedShade != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${_toTitleCase(provider.selectedShade!)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E6FBA),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                ShadeGrid(
                  shades: shades.map((s) => s.name).toList(),
                  selectedShades: provider.selectedShade != null ? {provider.selectedShade!} : {},
                  onShadeSelected: (shadeName) {
                    final isSelected = provider.selectedShade?.toLowerCase() == shadeName.toLowerCase();
                    provider.selectShade(isSelected ? null : shadeName);
                  },
                ),
              ],
            ),
          ],

          // 2. SIZE ROW (Shown once a shade is selected)
          if (provider.selectedShade != null) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 105,
                  child: Text(
                    'SIZE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Size Dropdown near to SIZE text
                Row(
                  children: [
                    Container(
                      width: 150,
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: provider.selectedSize != null
                              ? const Color(0xFF1E6FBA)
                              : const Color(0xFFCCCCCC),
                          width: provider.selectedSize != null ? 1.5 : 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          key: const Key('size_dropdown'),
                          isExpanded: true,
                          value: provider.availableSizes.contains(provider.selectedSize)
                              ? provider.selectedSize
                              : null,
                          hint: Text(
                            provider.isLoadingSizes
                                ? 'Loading sizes...'
                                : provider.availableSizes.isEmpty
                                    ? 'No Size Available'
                                    : 'Select Size',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF888888),
                            ),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xFF555555),
                          ),
                          isDense: true,
                          menuMaxHeight: 320,
                          borderRadius: BorderRadius.circular(10),
                          items: provider.availableSizes.map((size) {
                            final isPremium = MeleeConstants.isPremiumSize(size);
                            return DropdownMenuItem<String>(
                              value: size,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    size,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF222222),
                                    ),
                                  ),
                                  if (isPremium) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEBEE),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'P',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFFE53935),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (newSize) {
                            if (newSize != null) {
                              provider.selectSize(newSize);
                              if (MeleeConstants.isPremiumSize(newSize)) {
                                _showPremiumSizeDialog(context, newSize);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (provider.isPremiumSizeSelected) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const SizedBox(width: 113),
                  GestureDetector(
                    onTap: () => _showPremiumSizeDialog(context, provider.selectedSize!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFFCDD2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, size: 12, color: Color(0xFFE53935)),
                          const SizedBox(width: 4),
                          Text(
                            'Premium Size (Tap for details)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Commented out as per request: size dropdown is now shown near to SIZE text
            /*
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: provider.availableSizes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final size = provider.availableSizes[index];
                  final isSelected = provider.selectedSize == size;
                  final isPremium = MeleeConstants.isPremiumSize(size);

                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        provider.selectSize(null);
                      } else {
                        provider.selectSize(size);
                        if (isPremium) {
                          _showPremiumSizeDialog(context, size);
                        }
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEBF5FF)
                            : isPremium
                                ? const Color(0xFFFFF8F8)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1E6FBA)
                              : isPremium
                                  ? const Color(0xFFFFCDD2)
                                  : const Color(0xFFCCCCCC),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: const Color(0xFF1E6FBA).withAlpha(40),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            )
                          else
                            const BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            size,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF1E6FBA)
                                  : isPremium
                                      ? const Color(0xFFD32F2F)
                                      : const Color(0xFF333333),
                            ),
                          ),
                          if (isPremium) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'P',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFE53935),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            */
          ],

          // 3. CLARITY ROW (Shown once size is selected)
          if (provider.selectedShade != null && provider.selectedSize != null) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 105,
                  child: Text(
                    'CLARITY',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Clarity Dropdown near to CLARITY text
                Row(
                  children: [
                    Container(
                      width: 150,
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: provider.selectedGrade != null
                              ? const Color(0xFF1E6FBA)
                              : const Color(0xFFCCCCCC),
                          width: provider.selectedGrade != null ? 1.5 : 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          key: const Key('clarity_dropdown'),
                          isExpanded: true,
                          value: provider.availableGrades.contains(provider.selectedGrade)
                              ? provider.selectedGrade
                              : null,
                          hint: Text(
                            provider.isLoadingGrades
                                ? 'Loading clarity...'
                                : provider.availableGrades.isEmpty
                                    ? 'No Clarity Available'
                                    : 'Select Clarity',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF888888),
                            ),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xFF555555),
                          ),
                          isDense: true,
                          menuMaxHeight: 280,
                          borderRadius: BorderRadius.circular(10),
                          items: provider.availableGrades.map((grade) {
                            return DropdownMenuItem<String>(
                              value: grade,
                              child: Text(
                                grade,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF222222),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newGrade) {
                            provider.selectGrade(newGrade);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Commented out as per design update (clarity dropdown now used near CLARITY label)
            /*
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.availableGrades.map((grade) {
                final isSelected = provider.selectedGrade == grade;
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      provider.selectGrade(null);
                    } else {
                      provider.selectGrade(grade);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEBF5FF) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1E6FBA) : const Color(0xFFCCCCCC),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: const Color(0xFF1E6FBA).withAlpha(40),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                      ],
                    ),
                    child: Text(
                      grade,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF1E6FBA) : const Color(0xFF333333),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            */
          ],

            // 4. NUMBER OF DIAMONDS & PRICE PER CARAT (Shown once clarity is selected)
            if (provider.selectedShade != null &&
                provider.selectedSize != null &&
                provider.selectedGrade != null) ...[
              const SizedBox(height: 16),
              if (!hasValidQuantity) ...[
                // State 1: Quantity is empty (Matching media_1788514814150.png)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 105,
                      child: Text(
                        'NUMBER OF\nDIAMONDS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: const Color(0xFF333333),
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildQuantityBox(width: 150),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 125,
                    height: 36,
                    child: _buildResetFilterButton(provider),
                  ),
                ),
              ] else ...[
                // State 2: Quantity entered (Matching media_1788514829105.png)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktopOrTablet = constraints.maxWidth >= 520;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: NUMBER OF DIAMONDS & PRICE PER CARAT
                        if (isDesktopOrTablet) ...[
                          Row(
                            children: [
                              // Left: NUMBER OF DIAMONDS
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 105,
                                      child: Text(
                                        'NUMBER OF\nDIAMONDS',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                          color: const Color(0xFF333333),
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildQuantityBox(width: 150),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Right: PRICE PER CARAT (Clearly styled read-only badge)
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 85,
                                      child: Text(
                                        'PRICE PER\nCARAT',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                          color: const Color(0xFF333333),
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildDisplayBox(
                                      width: 150,
                                      isReadOnlyBadge: true,
                                      text: provider.calculation.pricePerCarat.isNotEmpty
                                          ? provider.calculation.pricePerCarat
                                          : '\$635',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Mobile Layout: Each on its own row, both matching 105 label width and 150 width box!
                          Row(
                            children: [
                              SizedBox(
                                width: 105,
                                child: Text(
                                  'NUMBER OF\nDIAMONDS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: const Color(0xFF333333),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildQuantityBox(width: 150),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                width: 105,
                                child: Text(
                                  'PRICE PER\nCARAT',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: const Color(0xFF333333),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildDisplayBox(
                                width: 150,
                                isReadOnlyBadge: true,
                                text: provider.calculation.pricePerCarat.isNotEmpty
                                    ? provider.calculation.pricePerCarat
                                    : '\$635',
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 14),

                        // Row 2: ESTIMATE CARAT WEIGHT & ESTIMATE VALUE USD
                        if (isDesktopOrTablet) ...[
                          Row(
                            children: [
                              // ESTIMATE CARAT WEIGHT
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 105,
                                      child: Text(
                                        'ESTIMATE\nCARAT WEIGHT',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                          color: const Color(0xFF333333),
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildDisplayBox(
                                              text: provider.calculation.wtFrom.isNotEmpty
                                                  ? provider.calculation.wtFrom
                                                  : '0.0150',
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            child: Text(
                                              'To',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF333333),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: _buildDisplayBox(
                                              text: provider.calculation.wtTo.isNotEmpty
                                                  ? provider.calculation.wtTo
                                                  : '0.0250',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // ESTIMATE VALUE USD
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 85,
                                      child: Text(
                                        'ESTIMATE\nVALUE USD',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                          color: const Color(0xFF333333),
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildDisplayBox(
                                              text: provider.calculation.priceFrom.isNotEmpty
                                                  ? provider.calculation.priceFrom
                                                  : '\$9.53',
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            child: Text(
                                              'To',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF333333),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: _buildDisplayBox(
                                              text: provider.calculation.priceTo.isNotEmpty
                                                  ? provider.calculation.priceTo
                                                  : '\$15.88',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Mobile Layout: Each row has label on left
                          Row(
                            children: [
                              SizedBox(
                                width: 105,
                                child: Text(
                                  'ESTIMATE\nCARAT WEIGHT',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: const Color(0xFF333333),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildDisplayBox(
                                        text: provider.calculation.wtFrom.isNotEmpty
                                            ? provider.calculation.wtFrom
                                            : '0.0150',
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6),
                                      child: Text(
                                        'To',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildDisplayBox(
                                        text: provider.calculation.wtTo.isNotEmpty
                                            ? provider.calculation.wtTo
                                            : '0.0250',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                width: 105,
                                child: Text(
                                  'ESTIMATE\nVALUE USD',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: const Color(0xFF333333),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildDisplayBox(
                                        text: provider.calculation.priceFrom.isNotEmpty
                                            ? provider.calculation.priceFrom
                                            : '\$9.53',
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6),
                                      child: Text(
                                        'To',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildDisplayBox(
                                        text: provider.calculation.priceTo.isNotEmpty
                                            ? provider.calculation.priceTo
                                            : '\$15.88',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 14),

                        // Row 3: COMMENT
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 105,
                              child: Text(
                                'COMMENT',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 38,
                                  child: TextField(
                                    controller: _commentController,
                                    focusNode: _commentFocusNode,
                                    maxLines: 1,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF222222),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Special request',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF999999),
                                      fontSize: 12,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFF1E6FBA), width: 1.5),
                                    ),
                                  ),
                                  onChanged: provider.setSpecialRequest,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Row 4: Action Buttons [ Add To Cart ] & [ Reset Filter ] side-by-side (equal sizes)
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: _buildAddToCartButton(context, provider),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: _buildResetFilterButton(provider),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ] else ...[
              // Centered Reset Filter button when size or clarity is not yet selected
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 125,
                  height: 36,
                  child: _buildResetFilterButton(provider),
                ),
              ),
            ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Red outline hand pointing right to empty diamonds input box (Matching media_1788514814150.png)
class RedHandOutlinePointer extends StatelessWidget {
  final double width;
  final double height;

  const RedHandOutlinePointer({
    super.key,
    this.width = 30,
    this.height = 18,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _RedHandPointerPainter(),
    );
  }
}

class _RedHandPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFFFFEBEE)
      ..style = PaintingStyle.fill;

    // Coordinate system: 30 wide x 18 high
    final sx = size.width / 30.0;
    final sy = size.height / 18.0;

    final path = Path();
    // Start at bottom of wrist
    path.moveTo(2 * sx, 15 * sy);
    // Up along wrist/palm
    path.lineTo(2 * sx, 7 * sy);
    // Base of thumb
    path.lineTo(6 * sx, 4.5 * sy);
    // Thumb tip curved upwards
    path.quadraticBezierTo(8.5 * sx, 1.5 * sy, 11 * sx, 2.5 * sy);
    path.quadraticBezierTo(12.5 * sx, 4 * sy, 11 * sx, 6.5 * sy);
    // Notch between thumb and index finger
    path.lineTo(13 * sx, 6.5 * sy);
    // Index finger top edge pointing right
    path.lineTo(26.5 * sx, 6.5 * sy);
    // Index fingertip rounded
    path.quadraticBezierTo(29 * sx, 8.5 * sy, 26.5 * sx, 10.5 * sy);
    // Index finger bottom edge
    path.lineTo(16.5 * sx, 10.5 * sy);
    // Middle finger knuckle
    path.quadraticBezierTo(18 * sx, 12 * sy, 16 * sx, 13 * sy);
    // Ring finger knuckle
    path.quadraticBezierTo(17 * sx, 14.5 * sy, 15 * sx, 15.5 * sy);
    // Pinky finger knuckle
    path.quadraticBezierTo(14.5 * sx, 17 * sy, 11 * sx, 17 * sy);
    // Back to wrist
    path.lineTo(2 * sx, 15 * sy);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Subtle knuckle crease line
    final foldPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(13 * sx, 7.5 * sy),
      Offset(13 * sx, 14.5 * sy),
      foldPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
