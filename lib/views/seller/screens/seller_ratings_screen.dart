import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/product_model.dart';
import 'package:online_perfume_app_fyp/models/review_model.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';
import 'package:online_perfume_app_fyp/services/product_service.dart';
import 'package:online_perfume_app_fyp/services/review_service.dart';

class SellerRatingsScreen extends StatefulWidget {
  final SellerModel seller;
  const SellerRatingsScreen({super.key, required this.seller});

  @override
  State<SellerRatingsScreen> createState() => _SellerRatingsScreenState();
}

class _SellerRatingsScreenState extends State<SellerRatingsScreen> {
  final ProductService _productService = ProductService();
  final ReviewService  _reviewService  = ReviewService();

  bool isLoadingProducts = false;
  bool isLoadingReviews  = false;
  bool isReplying        = false;

  List<ProductModel> _products = [];
  List<ReviewModel>  _reviews  = [];

  // Currently selected product
  ProductModel? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // ── Load seller products
  Future<void> _loadProducts() async {
    try {
      setState(() => isLoadingProducts = true);

      final products = await _productService
          .getSellerProducts(widget.seller.docId ?? '');

      setState(() {
        _products = products;
        isLoadingProducts = false;
      });

      // Auto-select first product
      if (_products.isNotEmpty) {
        _selectProduct(_products.first);
      }
    } catch (e) {
      setState(() => isLoadingProducts = false);
      _showError(e.toString());
    }
  }

  // ── Select product and load its reviews
  Future<void> _selectProduct(ProductModel product) async {
    setState(() {
      _selectedProduct = product;
      _reviews = [];
      isLoadingReviews = true;
    });

    try {
      final reviews = await _reviewService
          .getProductReviewModels(product.docId ?? '');
      setState(() {
        _reviews = reviews;
        isLoadingReviews = false;
      });
    } catch (e) {
      setState(() => isLoadingReviews = false);
      _showError(e.toString());
    }
  }

  // ── Calculate rating breakdown from reviews
  // Returns list of 5 percentages [5star%, 4star%, 3star%, 2star%, 1star%]
  List<double> _getRatingBreakdown() {
    if (_reviews.isEmpty) return [0, 0, 0, 0, 0];

    final counts = [0, 0, 0, 0, 0]; // index 0 = 5 stars
    for (final r in _reviews) {
      final star = (r.rating ?? 0).round();
      if (star >= 1 && star <= 5) {
        counts[5 - star]++;
      }
    }

    return counts
        .map((c) => _reviews.isEmpty ? 0.0 : (c / _reviews.length) * 100)
        .toList();
  }

  // ── Calculate average rating from reviews
  double _getAvgRating() {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold(0.0, (s, r) => s + (r.rating ?? 0));
    return double.parse((total / _reviews.length).toStringAsFixed(1));
  }

  // ── Post or edit reply
  Future<void> _postReply(ReviewModel review, String replyText) async {
    try {
      setState(() => isReplying = true);

      await _reviewService.replyToReview(
        reviewId:    review.reviewId ?? '',
        sellerReply: replyText,
      );

      // Update locally without full reload
      final idx = _reviews.indexWhere((r) => r.reviewId == review.reviewId);
      if (idx != -1) {
        _reviews[idx] = ReviewModel.fromJson({
          ...review.toJson(review.docId ?? ''),
          'sellerReply': replyText,
          'repliedAt':   DateTime.now().millisecondsSinceEpoch,
        });
      }

      setState(() => isReplying = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Reply posted successfully',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: const Color(0xffD08C4A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      setState(() => isReplying = false);
      _showError(e.toString());
    }
  }

  // ── Show reply bottom sheet
  void _showReplySheet(ReviewModel review) {
    final replyController =
    TextEditingController(text: review.sellerReply ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
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
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),

            Text('Reply to Review',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04))),
            const SizedBox(height: 12),

            // Original review box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(review.buyerName ?? '',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff5E1D04))),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < (review.rating ?? 0).round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 14,
                        color: const Color(0xffD08C4A),
                      )),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(review.comment ?? '',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Text('Your Reply',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff5E1D04))),
            const SizedBox(height: 8),

            TextField(
              controller: replyController,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Write your response here...',
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

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (replyController.text.isNotEmpty) {
                    Navigator.pop(context);
                    _postReply(review, replyController.text.trim());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please write a reply first',
                          style: GoogleFonts.poppins(fontSize: 13)),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD08C4A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
                child: Text('Post Reply',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    final breakdown = _getRatingBreakdown();
    final avgRating = _getAvgRating();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios,
              color: Color(0xff5E1D04), size: 20),
        ),
        title: Text('Ratings & Reviews',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5E1D04))),
        centerTitle: true,
      ),
      body: isLoadingProducts
          ? const Center(
          child: CircularProgressIndicator(color: Color(0xffD08C4A)))
          : _products.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined,
                size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No products found',
                style: GoogleFonts.poppins(
                    fontSize: 14, color: Colors.grey.shade400)),
          ],
        ),
      )
          : RefreshIndicator(
        color: const Color(0xffD08C4A),
        onRefresh: _loadProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ── Product Selector
              Text('Select Product',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff5E1D04))),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _products.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final p = _products[index];
                    final isSelected =
                        _selectedProduct?.docId == p.docId;
                    return GestureDetector(
                      onTap: () => _selectProduct(p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xffD08C4A)
                              : const Color(0xFFF9F9F9),
                          borderRadius:
                          BorderRadius.circular(20),
                          border: Border.all(
                              color: isSelected
                                  ? const Color(0xffD08C4A)
                                  : const Color(0xFFEEEEEE)),
                        ),
                        child: Text(p.name ?? '',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ── Rating Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFEEEEEE))),
                child: Row(children: [
                  // Big rating number
                  Column(children: [
                    Text(
                      _reviews.isEmpty
                          ? '0.0'
                          : '$avgRating',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff5E1D04)),
                    ),
                    Row(
                      children: List.generate(
                          5,
                              (i) => Icon(
                            i < avgRating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: const Color(0xffD08C4A),
                          )),
                    ),
                    const SizedBox(height: 4),
                    Text('${_reviews.length} reviews',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade500)),
                  ]),
                  const SizedBox(width: 20),

                  // Breakdown bars
                  Expanded(
                    child: Column(
                      children: List.generate(5, (i) {
                        final star = 5 - i;
                        final pct = breakdown[i];
                        return Padding(
                          padding:
                          const EdgeInsets.only(bottom: 4),
                          child: Row(children: [
                              Text('$star',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color:
                                  Colors.grey.shade500)),
                          const SizedBox(width: 4),
                          const Icon(Icons.star,
                              size: 11,
                              color: Color(0xffD08C4A)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                  value: pct / 100,
                                  minHeight: 7,
                                  backgroundColor:
                                  Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xffD08C4A),
                                ),
                          ),
                        ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: GoogleFonts.poppins(
                        fontSize: 10,
                        color:
                        Colors.grey.shade500)),
                        ]),
                        );
                        }),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // ── Reviews header
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text('Customer Reviews',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff5E1D04))),
                  Text('${_reviews.length} reviews',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade500)),
                ],
              ),
              const SizedBox(height: 12),

              // ── Reviews list
              isLoadingReviews
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(
                      color: Color(0xffD08C4A)),
                ),
              )
                  : _reviews.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(children: [
                    Icon(Icons.star_outline,
                        size: 50,
                        color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text('No reviews yet',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color:
                            Colors.grey.shade400)),
                  ]),
                ),
              )
                  : Column(
                children: _reviews
                    .map((review) => _ReviewTile(
                  review: review,
                  formatDate: _formatDate,
                  onReply: () =>
                      _showReplySheet(review),
                ))
                    .toList(),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Review Tile
class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  final String Function(int?) formatDate;
  final VoidCallback onReply;

  const _ReviewTile({
    required this.review,
    required this.formatDate,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final hasReply = (review.sellerReply ?? '').isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer info
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFFFF3CD),
              child: Text(
                (review.buyerName ?? 'B').isNotEmpty
                    ? review.buyerName![0].toUpperCase()
                    : 'B',
                style: GoogleFonts.poppins(
                    fontSize: 14,
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
                            color: const Color(0xffD08C4A),
                          )),
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
          const SizedBox(height: 10),

          // Review text
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
                        size: 13, color: Color(0xff66BB6A)),
                    const SizedBox(width: 4),
                    Text('Your Reply',
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

          const SizedBox(height: 10),

          // Reply button
          GestureDetector(
            onTap: onReply,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.reply, size: 15, color: const Color(0xffD08C4A)),
                const SizedBox(width: 4),
                Text(
                  hasReply ? 'Edit Reply' : 'Reply',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xffD08C4A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}