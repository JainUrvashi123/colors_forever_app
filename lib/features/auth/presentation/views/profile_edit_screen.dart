import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../melee/presentation/providers/melee_provider.dart';
import '../../../diamonds/presentation/providers/diamond_catalog_provider.dart';
import '../../data/models/user_profile_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/logout_confirmation_dialog.dart';
import 'login_screen.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  static Future<void> show(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.userProfile == null) {
      await authProvider.fetchProfile();
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const ProfileEditScreen(),
      ),
    );
  }

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _fullNameController;
  late TextEditingController _companyController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _faxController;
  late TextEditingController _addressController;
  late TextEditingController _usernameController;
  late TextEditingController _meleeMarkupController;
  late TextEditingController _diamondMarkupController;
  late TextEditingController _jewelryMarkupController;

  String _oldLogoName = 'old_logo.png';
  XFile? _pickedLogoFile;
  bool _useMarkup = true;
  bool _hidePrice = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final profile = authProvider.userProfile ?? UserProfileResponse.mockProfile;
    final details = profile.details;
    final diamondM = profile.diamondMarkup;
    final jewelryM = profile.jewelryMarkup;
    final meleeM = profile.meleeMarkup;

    _fullNameController = TextEditingController(text: details?.fullName ?? 'John Smith');
    _companyController = TextEditingController(text: details?.companyName ?? 'Pankaj');
    _phoneController = TextEditingController(text: details?.mobile ?? '9876543210');
    _websiteController = TextEditingController(text: details?.companyWebsite ?? 'https://abcjewelry.com');
    _faxController = TextEditingController(text: details?.fax ?? '123456');
    _addressController = TextEditingController(text: details?.address ?? 'New York, USA');
    _usernameController = TextEditingController(text: details?.username ?? 'praveen@braintreeproducts.com');

    _meleeMarkupController = TextEditingController(text: meleeM?.userMarkup ?? '20');
    _diamondMarkupController = TextEditingController(text: diamondM?.userMarkup ?? '10');
    _jewelryMarkupController = TextEditingController(text: jewelryM?.userMarkup ?? '15');

    _oldLogoName = details?.companyLogo.isNotEmpty == true ? details!.companyLogo : 'old_logo.png';
    _useMarkup = diamondM?.isMarkupActive ?? true;
    _hidePrice = diamondM?.isPriceHidden ?? false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _faxController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    _meleeMarkupController.dispose();
    _diamondMarkupController.dispose();
    _jewelryMarkupController.dispose();
    super.dispose();
  }

  // ignore: unused_element
  Future<void> _pickCompanyLogo() async {
    try {
      XFile? pickedFile;

      // 1. Try file_selector for Desktop (Windows, macOS, Linux, Web)
      const typeGroup = XTypeGroup(
        label: 'images',
        extensions: <String>['jpg', 'jpeg', 'png', 'gif'],
        mimeTypes: <String>['image/jpeg', 'image/png', 'image/gif'],
      );

      try {
        pickedFile = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
      } catch (_) {}

      // 2. Fallback to image_picker for Mobile (Android, iOS)
      if (pickedFile == null) {
        try {
          pickedFile = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          );
        } catch (_) {}
      }

      if (pickedFile != null) {
        setState(() {
          _pickedLogoFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick logo image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final authProvider = context.read<AuthProvider>();

    final response = await authProvider.submitProfile(
      name: _fullNameController.text.trim(),
      company: _companyController.text.trim(),
      website: _websiteController.text.trim(),
      email: _usernameController.text.trim(),
      phone: _phoneController.text.trim(),
      isDiamondWork: _useMarkup ? '1' : '0',
      companyLogoOld: _oldLogoName,
      fax: _faxController.text.trim(),
      address: _addressController.text.trim(),
      markupType: 'moneywise',
      markupD: _diamondMarkupController.text.trim(),
      markupJ: _jewelryMarkupController.text.trim(),
      markupM: _meleeMarkupController.text.trim(),
      price: _hidePrice ? '1' : '0',
      userId: authProvider.currentUser?.userId,
      logoFile: _pickedLogoFile,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  response.message.isNotEmpty ? response.message : 'Profile updated successfully!',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    } else {
      final isLoginRequired = response.message.toLowerCase().contains('login');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLoginRequired ? 'Session expired: Login First!' : (response.message.isNotEmpty ? response.message : 'Failed to submit profile update'),
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: isLoginRequired ? const Color(0xFFDC2626) : Colors.red,
          duration: const Duration(seconds: 4),
          action: isLoginRequired
              ? SnackBarAction(
                  label: 'LOG IN',
                  textColor: Colors.white,
                  onPressed: () async {
                    final auth = context.read<AuthProvider>();
                    final nav = Navigator.of(context);
                    final melee = context.read<MeleeProvider>();
                    final diamondCatalog = context.read<DiamondCatalogProvider>();
                    await auth.logout();
                    try {
                      diamondCatalog.clearCart();
                      await melee.clearLocalCart();
                      melee.resetFilter();
                    } catch (_) {}
                    if (!mounted) return;
                    nav.pop();
                    nav.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopOrTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Handle Bar & Close Button Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  const SizedBox(width: 32),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close, size: 18, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Profile Edit',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Update your company and pricing preferences.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                LogoutConfirmationDialog.show(context);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 44,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.logout, size: 16, color: Color(0xFFDC2626)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Log Out',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFDC2626),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const DashedDivider(),
                        const SizedBox(height: 16),

                        // Row 1: Fullname *
                        _buildFormRow(
                          label: 'Fullname *',
                          isDesktop: isDesktopOrTablet,
                          child: _buildInputField(
                            controller: _fullNameController,
                            hint: 'Full name',
                            icon: Icons.person_outline,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        _buildRowDivider(),

                        // Row 2: Company Name
                        _buildFormRow(
                          label: 'Company Name',
                          isDesktop: isDesktopOrTablet,
                          child: _buildInputField(
                            controller: _companyController,
                            hint: 'Company name',
                            icon: Icons.business_outlined,
                          ),
                        ),
                        _buildRowDivider(),

                        /*
                        // Row 3: Company Logo
                        _buildFormRow(
                          label: 'Company Logo',
                          isDesktop: isDesktopOrTablet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _pickCompanyLogo,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.champagneGold,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      icon: const Icon(Icons.upload_sharp, size: 16),
                                      label: Text(
                                        'Upload',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _pickedLogoFile != null
                                            ? _pickedLogoFile!.name
                                            : 'No file chosen',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: _pickedLogoFile != null
                                              ? AppColors.textPrimary
                                              : AppColors.textSecondary,
                                          fontWeight: _pickedLogoFile != null
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Only .jpg | .png | .gif file accepted.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildRowDivider(),
                        */

                        // Row 4: Phone
                        _buildFormRow(
                          label: 'Phone',
                          isDesktop: isDesktopOrTablet,
                          child: _buildInputField(
                            controller: _phoneController,
                            hint: 'Phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        _buildRowDivider(),

                        // Row 5: Website
                        _buildFormRow(
                          label: 'Website',
                          isDesktop: isDesktopOrTablet,
                          child: _buildInputField(
                            controller: _websiteController,
                            hint: 'Website URL',
                            icon: Icons.language_outlined,
                            keyboardType: TextInputType.url,
                          ),
                        ),
                        _buildRowDivider(),

                        // Row 6: Fax
                        _buildFormRow(
                          label: 'Fax',
                          isDesktop: isDesktopOrTablet,
                          child: _buildInputField(
                            controller: _faxController,
                            hint: 'Fax number',
                            icon: Icons.badge_outlined,
                          ),
                        ),
                        _buildRowDivider(),

                        // Row 7: Address
                        _buildFormRow(
                          label: 'Address',
                          isDesktop: isDesktopOrTablet,
                          child: _buildInputField(
                            controller: _addressController,
                            hint: 'Address',
                            icon: Icons.location_on_outlined,
                          ),
                        ),
                        _buildRowDivider(),

                        // Row 8: UserName *
                        _buildFormRow(
                          label: 'UserName *',
                          isDesktop: isDesktopOrTablet,
                          child: _buildInputField(
                            controller: _usernameController,
                            hint: 'Username / Email',
                            icon: Icons.mail_outline,
                            readOnly: true,
                            fillColor: const Color(0xFFF1F5F9),
                          ),
                        ),
                        _buildRowDivider(),

                        // Row 9: Mellees Diamond Markup % *
                        _buildFormRow(
                          label: 'Mellees Diamond Markup % *',
                          isDesktop: isDesktopOrTablet,
                          child: _buildInputField(
                            controller: _meleeMarkupController,
                            hint: '0',
                            suffixText: '%',
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        _buildRowDivider(),

                        // Row 10: Diamond Markup % *
                        _buildFormRow(
                          label: 'Diamond Markup % *',
                          isDesktop: isDesktopOrTablet,
                          child: _buildInputField(
                            controller: _diamondMarkupController,
                            hint: '0',
                            suffixText: '%',
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        _buildRowDivider(),

                        // Row 11: Jewelry Markup % *
                        _buildFormRow(
                          label: 'Jewelry Markup % *',
                          isDesktop: isDesktopOrTablet,
                          child: _buildInputField(
                            controller: _jewelryMarkupController,
                            hint: '0',
                            suffixText: '%',
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        _buildRowDivider(),

                        // Row 12: Use Markup
                        _buildFormRow(
                          label: 'Use Markup',
                          isDesktop: isDesktopOrTablet,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildCustomToggle(
                              value: _useMarkup,
                              activeColor: const Color(0xFF43A047),
                              onChanged: (val) => setState(() => _useMarkup = val),
                            ),
                          ),
                        ),
                        _buildRowDivider(),

                        // Row 13: Hide Price
                        _buildFormRow(
                          label: 'Hide Price',
                          isDesktop: isDesktopOrTablet,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildCustomToggle(
                              value: _hidePrice,
                              activeColor: const Color(0xFFE53935),
                              onChanged: (val) => setState(() => _hidePrice = val),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const DashedDivider(),
                        const SizedBox(height: 20),

                        // Action Buttons: Cancel & Update
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 130,
                              height: 46,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  side: const BorderSide(color: AppColors.champagneGold, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.richGold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              height: 46,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _handleUpdateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.champagneGold,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Text(
                                        'Update',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormRow({
    required String label,
    required Widget child,
    required bool isDesktop,
  }) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: child),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildRowDivider() {
    return Column(
      children: const [
        SizedBox(height: 14),
        DashedDivider(),
        SizedBox(height: 14),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    String? suffixText,
    bool readOnly = false,
    Color? fillColor,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: fillColor ?? Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        prefixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.textSecondary) : null,
        suffixIcon: suffixText != null
            ? Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  suffixText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.champagneGold, width: 1.6),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildCustomToggle({
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: value ? activeColor : const Color(0xFF94A3B8),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: (value ? activeColor : Colors.black).withAlpha(40),
              blurRadius: 4,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? const Alignment(-0.65, 0) : const Alignment(0.65, 0),
              child: Text(
                value ? 'ON' : 'OFF',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;

  const DashedDivider({
    super.key,
    this.height = 1,
    this.color = const Color(0xFFCBD5E1),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount > 0 ? dashCount : 1, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
