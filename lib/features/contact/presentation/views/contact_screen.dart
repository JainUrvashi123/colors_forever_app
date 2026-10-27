import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/recaptcha_box.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/contact_remote_data_source.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  final ContactRemoteDataSource _dataSource = ContactRemoteDataSource();

  bool _isCaptchaChecked = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillUserData();
    });
  }

  void _prefillUserData() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      final user = authProvider.currentUser;
      final profile = authProvider.userProfile?.details;

      if (_fullNameController.text.isEmpty) {
        _fullNameController.text = (profile != null && profile.fullName.isNotEmpty)
            ? profile.fullName
            : (user?.fullName ?? '');
      }
      if (_emailController.text.isEmpty) {
        if (profile != null && profile.email.isNotEmpty) {
          _emailController.text = profile.email;
        } else if (authProvider.savedUsername != null &&
            authProvider.savedUsername!.contains('@')) {
          _emailController.text = authProvider.savedUsername!;
        }
      }
      if (_mobileController.text.isEmpty &&
          profile != null &&
          profile.mobile.isNotEmpty) {
        _mobileController.text = profile.mobile;
      }
      if (_companyNameController.text.isEmpty) {
        _companyNameController.text = (profile != null && profile.companyName.isNotEmpty)
            ? profile.companyName
            : (user?.company ?? '');
      }
      if (_companyAddressController.text.isEmpty &&
          profile != null &&
          profile.address.isNotEmpty) {
        _companyAddressController.text = profile.address;
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isCaptchaChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please verify that you are not a robot.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await _dataSource.submitContactForm(
        fullname: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        companyName: _companyNameController.text.trim(),
        companyAddress: _companyAddressController.text.trim(),
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (!mounted) return;

      if (response.status == 1) {
        // Clear non-prefilled message/subject
        _subjectController.clear();
        _messageController.clear();
        setState(() => _isCaptchaChecked = false);

        _showSuccessDialog(response.message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isNotEmpty
                  ? response.message
                  : 'Failed to submit form. Please try again.',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error submitting contact form: $e',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 10),
            Text(
              'Thank You!',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          message.isNotEmpty
              ? message
              : 'Your request has been submitted successfully.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: AppColors.richGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border.withAlpha(140),
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 24,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Header: Contact Us
                    Center(
                      child: Text(
                        'Contact Us',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. Full Name
                    _buildInputField(
                      controller: _fullNameController,
                      hintText: 'John Smith',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // 2. Email Address
                    _buildInputField(
                      controller: _emailController,
                      hintText: 'praveen@braintreeproducts.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!val.contains('@') || !val.contains('.')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // 3. Mobile Number
                    _buildInputField(
                      controller: _mobileController,
                      hintText: '9876543210',
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // 4. Company Name
                    _buildInputField(
                      controller: _companyNameController,
                      hintText: 'Pankaj',
                    ),
                    const SizedBox(height: 14),

                    // 5. Company Address
                    _buildInputField(
                      controller: _companyAddressController,
                      hintText: 'New York, USA',
                    ),
                    const SizedBox(height: 14),

                    // 6. Subject
                    _buildInputField(
                      controller: _subjectController,
                      hintText: 'Subject',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // 7. Message / Feedback (Multiline)
                    _buildInputField(
                      controller: _messageController,
                      hintText: 'Type Your Message/Feedback here...',
                      maxLines: 4,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your message';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // 8. reCAPTCHA Card Container
                    RecaptchaBox(
                      value: _isCaptchaChecked,
                      onChanged: (val) => setState(() => _isCaptchaChecked = val),
                    ),
                    const SizedBox(height: 24),

                    // 9. Send Button (Pill button matching UI design)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF4A90E2),
                            width: 1.8,
                          ),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF7CB5EC),
                              Color(0xFF5B9BD5),
                            ],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x224A90E2),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isSubmitting ? null : _submitForm,
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 8,
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Send',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                            ),
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
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          color: const Color(0xFF94A3B8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFD6E2ED),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.richGold,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),
      validator: validator,
    );
  }
}
