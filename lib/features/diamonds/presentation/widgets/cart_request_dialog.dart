import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/session_manager.dart';
import '../providers/diamond_catalog_provider.dart';

class CartRequestDialog extends StatefulWidget {
  final String initialRequestType; // 'Email Cart' or 'Request Memo'
  final String initialCart; // 'All Cart', 'Loose Diamond Cart', or 'Jewelry Cart'

  const CartRequestDialog({
    super.key,
    this.initialRequestType = 'Request Memo',
    this.initialCart = 'All Cart',
  });

  @override
  State<CartRequestDialog> createState() => _CartRequestDialogState();
}

class _CartRequestDialogState extends State<CartRequestDialog> {
  late String _selectedCart;
  late String _selectedRequestType;
  late String _selectedShippingOption;

  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSending = false;

  final List<String> _cartOptions = [
    'All Cart',
    'Loose Diamond Cart',
    'Jewelry Cart',
  ];

  final List<String> _memoRequestTypeOptions = [
    'Select',
    'Memo',
    'Hold',
  ];

  final List<String> _shippingOptions = [
    'Select',
    'Overnight',
    'Second day',
    'Self Shipping Label',
  ];

  bool get _isMemoMode => widget.initialRequestType == 'Request Memo' || _selectedRequestType == 'Memo' || _selectedRequestType == 'Hold' || _selectedRequestType == 'Request Memo';

  bool get _shouldShowShippingOption => _isMemoMode && (_selectedRequestType == 'Memo' || _selectedRequestType == 'Request Memo');

  @override
  void initState() {
    super.initState();
    _selectedCart = widget.initialCart;

    if (widget.initialRequestType == 'Request Memo') {
      _selectedRequestType = 'Memo';
      _selectedShippingOption = 'Overnight';
    } else {
      _selectedRequestType = 'Email Cart';
      _selectedShippingOption = 'Select';
    }
  }

  @override
  void dispose() {
    _contactPersonController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitRequest() async {
    final provider = context.read<DiamondCatalogProvider>();
    if (_selectedCart == 'Loose Diamond Cart' && provider.cartCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least select one'),
          backgroundColor: Color(0xFFC62828),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    String recEmail = _emailController.text.trim();

    if (!_isMemoMode) {
      if (recEmail.isEmpty || !recEmail.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email address'),
            backgroundColor: Color(0xFFC62828),
          ),
        );
        return;
      }
    } else {
      if (recEmail.isEmpty) {
        recEmail = SessionManager.username ?? 'customer@example.com';
      }
    }

    setState(() => _isSending = true);

    final apiRequestType = !_isMemoMode
        ? 'Email Cart'
        : (_selectedRequestType == 'Hold' ? 'Hold' : 'Request Memo');

    final apiShippingOption = _shouldShowShippingOption
        ? (_selectedShippingOption == 'Select' ? '' : _selectedShippingOption)
        : '';

    final res = await provider.sendCartEmail(
      targetCart: _selectedCart,
      requestType: apiRequestType,
      recEmail: recEmail,
      contactPerson: _isMemoMode ? _contactPersonController.text.trim() : '',
      type: '',
      shippingOption: apiShippingOption,
      message: _messageController.text.trim(),
      markupD: '10',
    );

    if (mounted) {
      setState(() => _isSending = false);
      Navigator.of(context).pop();

      final isSuccess = res['status'] == 1 || res['status'] == '1';
      final msg = res['message']?.toString() ??
          '$apiRequestType request for $_selectedCart submitted successfully!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isSuccess ? AppColors.success : const Color(0xFFC62828),
          content: Text(msg),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _isMemoMode ? 'REQUEST MEMO/HOLD' : 'EMAIL CART';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title + Circle Close Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      titleText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 18, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 1. CART Dropdown (Shown in both)
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedCart,
                  items: _cartOptions.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCart = val);
                  },
                  decoration: _buildInputDecoration(labelText: 'CART'),
                ),
                const SizedBox(height: 18),

                // REQUEST MEMO/HOLD Mode Fields
                if (_isMemoMode) ...[
                  // 2. CONTACT PERSON
                  TextField(
                    controller: _contactPersonController,
                    decoration: _buildInputDecoration(labelText: 'CONTACT PERSON'),
                  ),
                  const SizedBox(height: 18),

                  // 3. MESSAGE
                  TextField(
                    controller: _messageController,
                    maxLines: 2,
                    decoration: _buildInputDecoration(labelText: 'MESSAGE'),
                  ),
                  const SizedBox(height: 18),

                  // 4. REQUEST TYPE Dropdown (Select / Memo / Hold)
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedRequestType,
                    items: _memoRequestTypeOptions.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRequestType = val);
                    },
                    decoration: _buildInputDecoration(labelText: 'REQUEST TYPE'),
                  ),
                  const SizedBox(height: 18),

                  // 5. SHIPPING OPTION (Visible ONLY if Request Type is Memo / Request Memo)
                  if (_shouldShowShippingOption) ...[
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedShippingOption,
                      items: _shippingOptions.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedShippingOption = val);
                      },
                      decoration: _buildInputDecoration(labelText: 'SHIPPING OPTION'),
                    ),
                    const SizedBox(height: 18),
                  ],
                ],

                // EMAIL CART Mode Fields (CART, EMAIL, MESSAGE)
                if (!_isMemoMode) ...[
                  // 2. EMAIL
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration(labelText: 'EMAIL'),
                  ),
                  const SizedBox(height: 18),

                  // 3. MESSAGE
                  TextField(
                    controller: _messageController,
                    maxLines: 2,
                    decoration: _buildInputDecoration(labelText: 'MESSAGE'),
                  ),
                  const SizedBox(height: 18),
                ],

                // 6. Send Button (Blue Pill Button matching web screenshot)
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _isSending ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5CA3DE),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: const BorderSide(color: Color(0xFF4A92D0), width: 1.2),
                      ),
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Send',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
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

  InputDecoration _buildInputDecoration({
    required String labelText,
  }) {
    return InputDecoration(
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E6FBA),
        letterSpacing: 0.5,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF1E6FBA), width: 1.5),
      ),
    );
  }
}
