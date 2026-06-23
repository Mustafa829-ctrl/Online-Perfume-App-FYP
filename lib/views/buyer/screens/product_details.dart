import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/product_model.dart';
import 'package:online_perfume_app_fyp/models/review_model.dart';
import 'package:online_perfume_app_fyp/services/cart_service.dart';
import 'package:online_perfume_app_fyp/services/review_service.dart';
import 'package:online_perfume_app_fyp/services/wishlist_service.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/bottom_navigation_bar.dart';
import 'package:online_perfume_app_fyp/views/buyer/widgets/product_details_widgets.dart';
import 'cart_screen.dart';

class ProductDetails extends StatefulWidget {
  final ProductModel product;
  final bool isLoggedIn;
  final VoidCallback onLoginRequired;

  const ProductDetails({
    super.key,
    required this.product,
    required this.isLoggedIn,
    required this.onLoginRequired,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final CartService     _cartService     = CartService();
  final WishlistService _wishlistService = WishlistService();
  final ReviewService   _reviewService   = ReviewService();

  // ── Selected size (from product.sizes)
  Map<String, dynamic>? _selectedSize;

  // ── Loading states
  bool _isAddingToCart  = false;
  bool _isLoadingReviews = false;
  bool _hasOrdered      = false; // whether buyer has delivered order for this product

  // ── Reviews
  List<ReviewModel> _reviews = [];

  // ── Review form
  double _reviewRating  = 5.0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();

    // Auto-select first size
    if (widget.product.sizes != null && widget.product.sizes!.isNotEmpty) {
      _selectedSize = widget.product.sizes!.first;
    }

    _loadReviews();
    if (widget.isLoggedIn) _checkIfOrdered();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // ── Load reviews
  Future<void> _loadReviews() async {
    try {
      setState(() => _isLoadingReviews = true);
      final reviews = await _reviewService
          .getProductReviewModels(widget.product.docId ?? '');
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (_) {
      setState(() => _isLoadingReviews = false);
    }
  }

  // ── Check if buyer has a delivered order for this product
  Future<void> _checkIfOrdered() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final snap = await FirebaseFirestore.instance
          .collection('orders')
          .where('buyerId',     isEqualTo: uid)
          .where('productId',   isEqualTo: widget.product.docId ?? '')
          .where('status',      isEqualTo: 'Delivered')
          .limit(1)
          .get();

      if (mounted) setState(() => _hasOrdered = snap.docs.isNotEmpty);
    } catch (_) {}
  }

  // ── Get selected price
  double get _selectedPrice {
    if (_selectedSize != null) {
      return double.tryParse(
          _selectedSize!['price'].toString()) ??
          widget.product.price ?? 0.0;
    }
    return widget.product.price ?? 0.0;
  }

  // ── Get selected size label
  String get _selectedSizeLabel {
    return _selectedSize?['size']?.toString() ?? '';
  }

  // ── Get formatted price with discount
  String get _formattedPrice {
    final discount = widget.product.discount ?? 0.0;
    if (discount > 0) {
      final discounted = _selectedPrice * (1 - discount / 100);
      return 'Rs ${discounted.toStringAsFixed(0)}';
    }
    return 'Rs ${_selectedPrice.toStringAsFixed(0)}';
  }

  // ── Fragrance notes as chips
  List<String> get _fragranceChips {
    final notes = widget.product.fragranceNotes ?? '';
    if (notes.isEmpty) return [];
    return notes
        .split(',')
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();
  }

  // ── Add to cart
  Future<void> _addToCart() async {
    if (!widget.isLoggedIn) {
      widget.onLoginRequired();
      return;
    }

    if (_selectedSize == null && widget.product.sizes != null &&
        widget.product.sizes!.isNotEmpty) {
      _showSnackBar('Please select a size first', isError: true);
      return;
    }

    try {
      setState(() => _isAddingToCart = true);

      final uid = FirebaseAuth.instance.currentUser!.uid;

      await _cartService.addToCart(
        buyerId:     uid,
        productId:   widget.product.docId ?? '',
        productName: widget.product.name ?? '',
        price:       _selectedPrice,
        quantity:    1,
        sellerId:    widget.product.sellerId ?? '',
        imageUrl:    widget.product.imageUrl ?? '',
      );

      setState(() => _isAddingToCart = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.product.name} added to cart!',
              style: const TextStyle(color: Color(0xff5E1D04)),
            ),
            backgroundColor: const Color(0xffF6B55E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'View Cart',
              textColor: const Color(0xff5E1D04),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CartScreen())),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isAddingToCart = false);
      _showSnackBar(e.toString(), isError: true);
    }
  }

  // ── Submit review
  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      _showSnackBar('Please write a review first', isError: true);
      return;
    }

    try {
      setState(() => _isSubmittingReview = true);

      final uid  = FirebaseAuth.instance.currentUser!.uid;
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final buyerName =
          (user.data() as Map<String, dynamic>?)?['name'] ?? 'Buyer';

      final reviewId =
          '${uid}_${widget.product.docId}_${DateTime.now().millisecondsSinceEpoch}';

      await _reviewService.addReview(
        reviewId:  reviewId,
        productId: widget.product.docId ?? '',
        buyerId:   uid,
        buyerName: buyerName,
        rating:    _reviewRating,
        comment:   _reviewController.text.trim(),
        sellerId:  widget.product.sellerId ?? '',
      );

      _reviewController.clear();
      setState(() {
        _reviewRating        = 5.0;
        _isSubmittingReview  = false;
      });

      await _loadReviews();

      if (mounted) Navigator.pop(context); // close bottom sheet
      _showSnackBar('Review submitted successfully');
    } catch (e) {
      setState(() => _isSubmittingReview = false);
      _showSnackBar(e.toString(), isError: true);
    }
  }

  // ── Show review bottom sheet
  void _showReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),

              Text('Write a Review',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04))),
              const SizedBox(height: 6),
              Text(widget.product.name ?? '',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 16),

              // Star rating selector
              Text('Your Rating',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff5E1D04))),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setSheetState(
                            () => _reviewRating = (i + 1).toDouble()),
                    child: Icon(
                      i < _reviewRating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: const Color(0xffD08C4A),
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Comment field
              Text('Your Review',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff5E1D04))),
              const SizedBox(height: 8),
              TextField(
                controller: _reviewController,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Share your experience with this fragrance...',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: Color(0xFFEEEEEE))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: Color(0xFFEEEEEE))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: Color(0xffD08C4A))),
                ),
              ),
              const SizedBox(height: 20),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmittingReview ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffD08C4A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0),
                  child: _isSubmittingReview
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : Text('Submit Review',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor:
      isError ? Colors.red.shade400 : const Color(0xffD08C4A),
      behavior: SnackBarBehavior.floating,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  String _formatDate(int? millis) {
    if (millis == null) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year.toString().substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Wishlist stream ID
    final wishlistItemId = '${uid}_${widget.product.docId ?? ''}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xff5E1D04), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Product Details',
            style: GoogleFonts.poppins(
                fontSize: 20,
                color: const Color(0xff5E1D04),
                fontWeight: FontWeight.w600)),
        centerTitle: true,

        //  Wishlist icon in app bar
        actions: [
          widget.isLoggedIn
              ? StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('wishlists')
                .doc(uid)
                .collection('items')
                .doc(wishlistItemId)
                .snapshots(),
            builder: (context, snapshot) {
              final bool isLiked =
                  snapshot.data?.exists ?? false;
              return IconButton(
                icon: Icon(
                  isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isLiked
                      ? const Color(0xffF6B55E)
                      : const Color(0xff5E1D04),
                ),
                onPressed: () async {
                  try {
                    await _wishlistService.toggleWishlist(
                      buyerId:   uid,
                      productId: widget.product.docId ?? '',
                      name:      widget.product.name ?? '',
                      price:     _selectedPrice,
                      imagePath: widget.product.imageUrl ?? '',
                      sellerId:  widget.product.sellerId ?? '',
                    );
                  } catch (e) {
                    _showSnackBar(e.toString(), isError: true);
                  }
                },
              );
            },
          )
              : IconButton(
            icon: const Icon(Icons.favorite_border,
                color: Color(0xff5E1D04)),
            onPressed: widget.onLoginRequired,
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ── Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.product.imageUrl != null &&
                  widget.product.imageUrl!.isNotEmpty
                  ? Image.network(
                widget.product.imageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 250,
                  color: const Color(0xFFFFF3CD),
                  child: const Center(
                    child: Icon(Icons.local_florist_outlined,
                        color: Color(0xffD08C4A), size: 60),
                  ),
                ),
              )
                  : Container(
                height: 250,
                color: const Color(0xFFFFF3CD),
                child: const Center(
                  child: Icon(Icons.local_florist_outlined,
                      color: Color(0xffD08C4A), size: 60),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Name + Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name ?? '',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff5E1D04),
                        ),
                      ),
                      if ((widget.product.brand ?? '').isNotEmpty)
                        Text(widget.product.brand ?? '',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formattedPrice,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xff5E1D04),
                      ),
                    ),
                    // Original price if discounted
                    if ((widget.product.discount ?? 0) > 0)
                      Text(
                        'Rs ${_selectedPrice.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // ── Rating row
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                (widget.product.rating ?? 0.0).toStringAsFixed(1),
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              Text(
                '(${widget.product.reviewCount ?? 0} reviews)',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey.shade500),
              ),
            ]),
            const SizedBox(height: 20),

            // ── Size selector (dynamic from product.sizes)
            if (widget.product.sizes != null &&
                widget.product.sizes!.isNotEmpty) ...[
              Text('Select Size',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04))),
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: widget.product.sizes!.map((sizeMap) {
                    final isSelected =
                        _selectedSize?['size'] == sizeMap['size'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: VolumeSelector(
                        volume: sizeMap['size']?.toString() ?? '',
                        isSelected: isSelected,
                        onTap: () =>
                            setState(() => _selectedSize = sizeMap),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // ── Description
            if ((widget.product.description ?? '').isNotEmpty) ...[
              Text('Description',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04))),
              const SizedBox(height: 8),
              Text(
                widget.product.description ?? '',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade600, height: 1.6),
              ),
              const SizedBox(height: 20),
            ],

            // ── Fragrance notes as display chips
            if (_fragranceChips.isNotEmpty) ...[
              Row(children: [
                Stack(alignment: Alignment.center, children: [
                  Transform.rotate(
                    angle: 0.785398,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xff5E1D04), width: 1.5),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(width: 8),
                Text('Fragrance Notes',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5E1D04))),
              ]),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _fragranceChips.map((note) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xff5E1D04),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      note,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xffF6B55E)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // ── Concentration + Category info row
            if ((widget.product.concentration ?? '').isNotEmpty ||
                (widget.product.category ?? '').isNotEmpty) ...[
              Row(children: [
                if ((widget.product.concentration ?? '').isNotEmpty)
                  _InfoChip(
                      label: widget.product.concentration ?? '',
                      icon: Icons.water_drop_outlined),
                const SizedBox(width: 8),
                if ((widget.product.category ?? '').isNotEmpty)
                  _InfoChip(
                      label: widget.product.category ?? '',
                      icon: Icons.category_outlined),
              ]),
              const SizedBox(height: 24),
            ],

            // ── Add to Cart button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isAddingToCart ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD08C4A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  shadowColor: Colors.black.withOpacity(0.5),
                  elevation: 8,
                ),
                child: _isAddingToCart
                    ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : Text(
                  'Add to Cart',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04)),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ── Reviews section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Customer Reviews',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5E1D04))),
                Text('${_reviews.length} reviews',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 12),

            // ── Write review button
            // Only show if logged in + has ordered this product
            if (widget.isLoggedIn && _hasOrdered) ...[
              GestureDetector(
                onTap: _showReviewSheet,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xffD08C4A), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rate_review_outlined,
                          color: Color(0xffD08C4A), size: 18),
                      const SizedBox(width: 8),
                      Text('Write a Review',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xffD08C4A))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else if (widget.isLoggedIn && !_hasOrdered) ...[
              // Logged in but not purchased
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xffD08C4A), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Purchase this product to leave a review',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xff5E1D04)),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
            ],

            // ── Reviews list
            _isLoadingReviews
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                    color: Color(0xffD08C4A)),
              ),
            )
                : _reviews.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Icon(Icons.star_outline,
                      size: 40, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text('No reviews yet',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade400)),
                ]),
              ),
            )
                : Column(
              children: _reviews
                  .map((r) => _ReviewCard(
                review: r,
                formatDate: _formatDate,
              ))
                  .toList(),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ── Info Chip (concentration, category)
class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Icon(icon, size: 13, color: const Color(0xffD08C4A)),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xff5E1D04))),
      ]),
    );
  }
}

// ── Review Card
class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final String Function(int?) formatDate;
  const _ReviewCard({required this.review, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final hasReply = (review.sellerReply ?? '').isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer info
          Row(children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFFFF3CD),
              child: Text(
                (review.buyerName ?? 'B').isNotEmpty
                    ? review.buyerName![0].toUpperCase()
                    : 'B',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffD08C4A)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.buyerName ?? '',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff5E1D04))),
                  Row(children: [
                    Row(
                      children: List.generate(
                          5,
                              (i) => Icon(
                              i < (review.rating ?? 0).round()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 13,
                              color: const Color(0xffD08C4A))),
                    ),
                    const SizedBox(width: 6),
                    Text(formatDate(review.createdAt),
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.grey.shade400)),
                  ]),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 8),

          // Comment
          Text(review.comment ?? '',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey.shade600)),

          // Seller reply
          if (hasReply) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.storefront_outlined,
                        size: 12, color: Color(0xff66BB6A)),
                    const SizedBox(width: 4),
                    Text('Seller Reply',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff66BB6A))),
                  ]),
                  const SizedBox(height: 2),
                  Text(review.sellerReply ?? '',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}