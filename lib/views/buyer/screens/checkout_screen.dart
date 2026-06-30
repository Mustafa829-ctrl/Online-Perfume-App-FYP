import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:online_perfume_app_fyp/models/cart_item_model.dart';
import 'package:online_perfume_app_fyp/services/cart_service.dart';
import 'package:online_perfume_app_fyp/services/order_service.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/bottom_navigation_bar.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/checkout_widgets.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0; // 0 = Address, 1 = Payment, 2 = Review

  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();

  List<CartItemModel> _cartItems = [];
  double _cartTotalAmount = 0.0;
  bool _isLoading = true;

  final String _buyerUid =
      FirebaseAuth.instance.currentUser?.uid ?? 'guest_buyer';

  // Address fields
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _hasAddress = false;
  final String _savedLabel = 'Home';
  String _savedName = '';
  String _savedAddress = '';
  String _savedPhone = '';

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCartData() async {
    try {
      setState(() => _isLoading = true);
      final items = await _cartService.getCartItems(_buyerUid);
      final total = await _cartService.getCartTotal(_buyerUid);
      setState(() {
        _cartItems = items;
        _cartTotalAmount = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xff5E1D04)),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            fontSize: 22,
            color: const Color(0xff5E1D04),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Color(0xffD08C4A)))
          : Column(
        children: [
          const SizedBox(height: 10),
          CheckoutStepper(currentStep: _currentStep),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(),
              ),
            ),
          ),
          CheckoutBottomBar(
            currentStep: _currentStep,
            onBack: () => setState(() => _currentStep--),
            onPrimaryAction: _onPrimaryAction,
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return AddressStep(
          key: const ValueKey('address'),
          hasAddress: _hasAddress,
          savedLabel: _savedLabel,
          savedName: _savedName,
          savedAddress: _savedAddress,
          savedPhone: _savedPhone,
          onAddNewAddress: () => _showAddAddressSheet(context),
        );
      case 1:
        return const PaymentStep(key: ValueKey('payment'));
      case 2:
        return ReviewStep(
          key: const ValueKey('review'),
          savedAddress: _savedAddress,
          cartItems: _cartItems,
          totalAmount: _cartTotalAmount,
        );
      default:
        return const SizedBox();
    }
  }

  Future<void> _onPrimaryAction() async {
    if (_currentStep == 0) {
      if (!_hasAddress) {
        _showSnackBar('Please add a delivery address first!', isError: true);
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    } else {
      // ── Place Order step
      if (_cartItems.isEmpty) {
        _showSnackBar('Your cart contains no items to order.', isError: true);
        return;
      }

      try {
        setState(() => _isLoading = true);

        final totalSnapshot = _cartTotalAmount;
        final shippingDestination = _savedAddress;

        // Convert cart items to raw map list for the service
        final List<Map<String, dynamic>> formattedItems =
        _cartItems.map((item) => item.toJson()).toList();

        // ✅ Option B: placeOrder creates ONE Firestore document with
        // all items in an 'items' array. Returns the real docId + orderId.
        // Cancelling this one document cancels the entire order (all products).
        final Map<String, String> result = await _orderService.placeOrder(
          buyerId: _buyerUid,
          buyerName: _savedName,
          buyerPhone: _savedPhone,
          buyerAddress: shippingDestination,
          cartItems: formattedItems,
        );

        final String realDocId = result['docId'] ?? '';
        final String realOrderId = result['orderId'] ?? '';

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OrderConfirmationScreen(
                docId: realDocId,        // ✅ real Firestore docId
                orderId: realOrderId,    // ✅ real orderId
                orderTotal: totalSnapshot,
                deliveryAddress: shippingDestination,
              ),
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showSnackBar(e.toString(), isError: true);
      }
    }
  }

  void _showSnackBar(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.poppins(
                color: const Color(0xff5E1D04), fontSize: 13)),
        backgroundColor:
        isError ? const Color(0xffF6B55E) : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xffD08C4A).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Delivery Address',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04)),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                  _nameCtrl, 'Full Name', Icons.person_outline),
              const SizedBox(height: 12),
              _buildTextField(
                  _addressCtrl, 'Street Address', Icons.home_outlined),
              const SizedBox(height: 12),
              _buildTextField(
                  _cityCtrl, 'City', Icons.location_city_outlined),
              const SizedBox(height: 12),
              _buildTextField(
                  _phoneCtrl, 'Phone Number', Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _hasAddress = true;
                        _savedName = _nameCtrl.text.trim();
                        _savedAddress =
                        '${_addressCtrl.text.trim()}, ${_cityCtrl.text.trim()}';
                        _savedPhone = _phoneCtrl.text.trim();
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD08C4A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 6,
                  ),
                  child: Text(
                    'Save Address',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5E1D04)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: const Color(0xff5E1D04)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            color: const Color(0xff5E1D04).withOpacity(0.5), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xffD08C4A)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: const Color(0xffD08C4A).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffD08C4A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: (v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }
}