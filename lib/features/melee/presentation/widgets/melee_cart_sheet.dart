import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/price_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/views/login_screen.dart';
import '../../../../core/widgets/guest_guard.dart';
import 'package:provider/provider.dart';
import '../../domain/models/melee_model.dart';
import '../providers/melee_provider.dart';

class MeleeCartSheet extends StatelessWidget {
  final MeleeProvider provider;

  const MeleeCartSheet({
    super.key,
    required this.provider,
  });

  static void show(BuildContext context, MeleeProvider provider) {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      GuestGuard.requireLogin(context, actionLabel: 'view your melee cart');
      return;
    }
    provider.refreshMelleIndex();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: MeleeCartSheet(provider: provider),
      ),
    );
  }

  InputDecoration _buildDialogInputDecoration(String labelText, {bool isAccentBorder = false}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: isAccentBorder ? const Color(0xFF1E6FBA) : const Color(0xFF94A3B8),
        letterSpacing: 0.5,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isAccentBorder ? const Color(0xFF1E6FBA) : const Color(0xFFCBD5E1), width: isAccentBorder ? 1.5 : 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isAccentBorder ? const Color(0xFF1E6FBA) : const Color(0xFFCBD5E1), width: isAccentBorder ? 1.5 : 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isAccentBorder ? const Color(0xFF1E6FBA) : const Color(0xFF70A9DA), width: 1.8),
      ),
    );
  }

  void _showEmailCartDialog(BuildContext context) {
    final emailController = TextEditingController(text: 'urvashijain1999@gmail.com');
    final messageController = TextEditingController(text: 'hiiii');
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(115),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(46),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Header: EMAIL CART Title + Round Close 'x' Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EMAIL CART',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A5568),
                        letterSpacing: 0.5,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 22),

                // Input 1: EMAIL
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                  decoration: _buildDialogInputDecoration('EMAIL'),
                ),
                const SizedBox(height: 18),

                // Input 2: MESSAGE
                Stack(
                  children: [
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E293B),
                      ),
                      decoration: _buildDialogInputDecoration('MESSAGE'),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: IgnorePointer(
                        child: CustomPaint(
                          size: const Size(10, 10),
                          painter: _TextareaResizeHandlePainter(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Button: SEND (Pill / Stadium Button with Airplane Send Icon)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF1E6FBA), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF70A9DA).withAlpha(64),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF70A9DA),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final recEmailInput = emailController.text.trim();
                              final recEmail = recEmailInput.isNotEmpty
                                  ? recEmailInput
                                  : 'urvashijain1999@gmail.com';

                              setState(() => isSubmitting = true);

                              try {
                                final msgInput = messageController.text.trim();
                                final msg = msgInput.isNotEmpty
                                    ? msgInput
                                    : 'Please check this Melle diamond cart.';

                                final res = await provider.emailCart(
                                  recEmail: recEmail,
                                  message: msg,
                                );

                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                }

                                if (context.mounted) {
                                  final responseMsg = res['message']?.toString() ?? 'Cart emailed successfully!';
                                  final isSuccess = res['status'] == 1 || res['status'] == '1';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: isSuccess ? AppColors.midnightOnyx : Colors.redAccent,
                                      content: Text(
                                        responseMsg,
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                debugPrint('Email cart error: $e');
                              } finally {
                                if (ctx.mounted) {
                                  setState(() => isSubmitting = false);
                                }
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Transform.rotate(
                                  angle: -0.2,
                                  child: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'SEND',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPlaceOrderDialog(BuildContext context) {
    final contactController = TextEditingController();
    final messageController = TextEditingController();
    final addressController = TextEditingController();
    String shippingOption = 'Select';

    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(115),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(46),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modal Header: PLACE ORDER Title + Round Close 'x' Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PLACE ORDER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4A5568),
                          letterSpacing: 0.5,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(15),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 20),

                  // Input 1: CONTACT PERSON
                  TextField(
                    controller: contactController,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                    decoration: _buildDialogInputDecoration('CONTACT PERSON'),
                  ),
                  const SizedBox(height: 16),

                  // Input 2: MESSAGE
                  Stack(
                    children: [
                      TextField(
                        controller: messageController,
                        maxLines: 2,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E293B),
                        ),
                        decoration: _buildDialogInputDecoration('MESSAGE'),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: IgnorePointer(
                          child: CustomPaint(
                            size: const Size(10, 10),
                            painter: _TextareaResizeHandlePainter(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Input 3: SHIPPING OPTION Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: shippingOption,
                    decoration: _buildDialogInputDecoration('SHIPPING OPTION', isAccentBorder: true),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF333333)),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Select', child: Text('Select')),
                      DropdownMenuItem(value: 'Overnight', child: Text('Overnight')),
                      DropdownMenuItem(value: 'Second day', child: Text('Second day')),
                      DropdownMenuItem(value: 'Self Shipping Label', child: Text('Self Shipping Label')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => shippingOption = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Input 4: SHIPPING ADDRESS
                  Stack(
                    children: [
                      TextField(
                        controller: addressController,
                        maxLines: 2,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E293B),
                        ),
                        decoration: _buildDialogInputDecoration('SHIPPING ADDRESS'),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: IgnorePointer(
                          child: CustomPaint(
                            size: const Size(10, 10),
                            painter: _TextareaResizeHandlePainter(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Button: SEND
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFF1E6FBA), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF70A9DA).withAlpha(64),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF70A9DA),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final contactInput = contactController.text.trim();
                                final contactPerson = contactInput.isNotEmpty ? contactInput : 'Valued Customer';

                                final selectedShipping = shippingOption != 'Select' ? shippingOption : 'Overnight';

                                final addressInput = addressController.text.trim();
                                final shippingAddress = addressInput.isNotEmpty ? addressInput : 'Address on file';

                                final msgInput = messageController.text.trim();
                                final msg = msgInput.isNotEmpty ? msgInput : 'Please process this order';

                                setState(() => isSubmitting = true);

                                try {
                                  final res = await provider.placeOrder(
                                    contactPerson: contactPerson,
                                    message: msg,
                                    shippingOption: selectedShipping,
                                    shippingAddress: shippingAddress,
                                  );

                                  // Instantly clear cart locally and on server
                                  await provider.clearCart();

                                  if (ctx.mounted) {
                                    Navigator.pop(ctx);
                                  }

                                  if (context.mounted) {
                                    final responseMsg = res['message']?.toString() ?? 'Order placed successfully!';
                                    final isSuccess = res['status'] == 1 || res['status'] == '1';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: isSuccess ? AppColors.midnightOnyx : Colors.redAccent,
                                        content: Text(
                                          responseMsg,
                                          style: GoogleFonts.plusJakartaSans(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  debugPrint('Place order error: $e');
                                } finally {
                                  if (ctx.mounted) {
                                    setState(() => isSubmitting = false);
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: -0.2,
                                    child: const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SEND',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MeleeProvider>(
      builder: (context, activeProvider, _) {
        final items = activeProvider.cartItems;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 6),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_bag_outlined, color: AppColors.richGold, size: 22),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Melee Cart (${items.length})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (items.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _showDeleteConfirmDialog(
                            context,
                            title: 'Clear Entire Melee Cart?',
                            content: 'Are you sure you want to remove all ${items.length} parcel(s) from your melee cart?',
                            confirmLabel: 'Clear All Cart',
                            onConfirm: () async {
                              final res = await activeProvider.clearCart();
                              if (context.mounted) {
                                final msg = res['message']?.toString() ?? 'Melee cart cleared successfully!';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(msg),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              }
                            },
                          );
                        },
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (activeProvider.isCartUpdating)
                const SizedBox(
                  height: 2.5,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.richGold),
                  ),
                )
              else
                const Divider(height: 1),

              // Items List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.grain_rounded, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'Your Melee Cart is Empty',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Configure a diamond parcel above and tap "Add To Cart".',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildCartItemCard(context, item);
                        },
                      ),
              ),

              // Bottom Summary & Action Bar
              if (items.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF9F5),
                    border: Border(top: BorderSide(color: AppColors.border.withAlpha(120))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Total Stones: ${activeProvider.cartTotalStones}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Est. Carats: ${activeProvider.cartTotalMinWeight.toStringAsFixed(3)} - ${activeProvider.cartTotalMaxWeight.toStringAsFixed(3)} ct',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Estimated USD Value:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              final hidden = PriceHelper.isPriceHidden(auth, category: 'melee');
                              if (!auth.isAuthenticated) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.richGold),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Login to View Price',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.richGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Text(
                                hidden
                                    ? 'Price Upon Request'
                                    : '\$${activeProvider.cartTotalMinPrice.round()} - \$${activeProvider.cartTotalMaxPrice.round()}',
                                style: AppTheme.priceStyle(
                                  fontSize: hidden ? 14 : 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.richGold,
                                  letterSpacing: -0.3,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Place Order & Request Memo / Email Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E6FBA),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white, size: 18),
                              label: Text(
                                'Place Order',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                              onPressed: () => _showPlaceOrderDialog(context),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.midnightOnyx,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                side: const BorderSide(color: AppColors.champagneGold),
                              ),
                              icon: const Icon(Icons.email_outlined, color: AppColors.champagneGold, size: 18),
                              label: Text(
                                'Request Memo / Email',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              onPressed: () => _showEmailCartDialog(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartItemCard(BuildContext context, MeleeCartItem item) {
    final diamondAsset = AppAssets.getDiamondImageForShade(
      item.shade.isNotEmpty ? item.shade : item.color,
    );

    Widget thumbnailImage;
    if (item.previewImageUrl != null && item.previewImageUrl!.isNotEmpty) {
      thumbnailImage = CachedNetworkImage(
        imageUrl: item.previewImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => diamondAsset != null
            ? Image.asset(diamondAsset, fit: BoxFit.cover)
            : const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.champagneGold),
                ),
              ),
        errorWidget: (context, url, error) => diamondAsset != null
            ? Image.asset(diamondAsset, fit: BoxFit.cover)
            : Image.asset(AppAssets.meleeDiamonds, fit: BoxFit.cover),
      );
    } else if (diamondAsset != null) {
      thumbnailImage = Image.asset(
        diamondAsset,
        fit: BoxFit.cover,
      );
    } else {
      thumbnailImage = Image.asset(
        AppAssets.meleeDiamonds,
        fit: BoxFit.cover,
      );
    }

    final String titleText = item.stoneType == MeleeStoneType.birthstone && (item.month?.isNotEmpty ?? false)
        ? '${item.month} — ${item.color}'
        : (item.shade.isNotEmpty ? '${item.color} — ${item.shade}' : item.color);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Image Thumbnail (Expanded container and image size)
            Container(
              width: 95,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.champagneGold.withAlpha(120), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: thumbnailImage,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          titleText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          if (!auth.isAuthenticated) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.lock_outline_rounded, size: 10, color: AppColors.richGold),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Login for Price',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.richGold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          final hidden = PriceHelper.isPriceHidden(auth, category: 'melee');
                          return Text(
                            hidden ? 'Price Upon Request' : '${item.priceFrom} - ${item.priceTo}',
                            style: AppTheme.priceStyle(
                              fontSize: hidden ? 11.5 : 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.richGold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Size
                  _buildCartItemLine('Size', item.size),

                  // Clarity
                  _buildCartItemLine('Clarity', item.clarity),

                  // Quantity
                  _buildCartItemLine('Quantity', '${item.quantity} diamond(s)'),

                  // Est. Weight
                  _buildCartItemLine('Est. Weight', '${item.wtFrom} - ${item.wtTo} ct'),

                  // Price / Carat
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final hidden = PriceHelper.isPriceHidden(auth, category: 'melee');
                      return _buildCartItemLine(
                        'Price / Carat',
                        hidden ? 'Price Upon Request' : item.pricePerCarat,
                        valueColor: AppColors.richGold,
                      );
                    },
                  ),

                  // Note
                  if (item.specialRequest.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    _buildCartItemLine('Note', item.specialRequest, valueColor: AppColors.textSecondary, isItalic: true),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Action buttons: Edit and Remove
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.pop(context);
                    provider.editCartItem(item);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.champagneGold.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_outlined, size: 22, color: AppColors.richGold),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    _showDeleteConfirmDialog(
                      context,
                      title: 'Remove Melee Parcel?',
                      content: 'Are you sure you want to remove $titleText (${item.quantity} diamond(s)) from your melee cart?',
                      confirmLabel: 'Remove Parcel',
                      onConfirm: () async {
                        final res = await provider.removeFromCart(item.id);
                        if (context.mounted) {
                          final msg = res['message']?.toString() ?? 'Melee parcel removed successfully!';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              duration: const Duration(seconds: 2),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline, size: 22, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemLine(
    String label,
    String value, {
    Color? valueColor,
    bool isItalic = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.redAccent, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              confirmLabel,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextareaResizeHandlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width - 2, size.height), Offset(size.width, size.height - 2), paint);
    canvas.drawLine(Offset(size.width - 6, size.height), Offset(size.width, size.height - 6), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

