import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';
import 'package:online_perfume_app_fyp/models/expense_model.dart';
import '../../../services/expense_service.dart';

class SellerExpensesScreen extends StatefulWidget {
  final SellerModel seller;
  const SellerExpensesScreen({super.key, required this.seller});

  @override
  State<SellerExpensesScreen> createState() => _SellerExpensesScreenState();
}

class _SellerExpensesScreenState extends State<SellerExpensesScreen> {
  // Service
  final ExpenseService _expenseService = ExpenseService();

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // State
  bool isLoading = false;
  List<ExpenseModel> allExpenses = [];

  // Selected category filter
  String _selectedCategory = 'All';

  // Category options
  final List<String> _categories = [
    'All',
    'Delivery',
    'Marketing',
    'Electricity',
    'Rent',
    'Raw Material',
    'Packaging',
    'Other',
  ];

  // Category icons
  final Map<String, IconData> _categoryIcons = {
    'Delivery': Icons.delivery_dining_outlined,
    'Marketing': Icons.campaign_outlined,
    'Electricity': Icons.bolt_outlined,
    'Rent': Icons.home_outlined,
    'Raw Material': Icons.science_outlined,
    'Packaging': Icons.inventory_outlined,
    'Other': Icons.more_horiz_outlined,
  };

  // Category colors
  final Map<String, Color> _categoryColors = {
    'Delivery': const Color(0xff42A5F5),
    'Marketing': const Color(0xffAB47BC),
    'Electricity': const Color(0xffFFA726),
    'Rent': const Color(0xff66BB6A),
    'Raw Material': const Color(0xffEF5350),
    'Packaging': const Color(0xffD08C4A),
    'Other': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load expenses from Firebase
  Future<void> loadExpenses() async {
    try {
      isLoading = true;
      setState(() {});

      String sellerId = widget.seller.docId ?? '';
      allExpenses = await _expenseService.getSellerExpenses(sellerId);

      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // Filtered expenses
  List<ExpenseModel> get _filteredExpenses {
    List<ExpenseModel> result = allExpenses;

    // Search
    if (_searchController.text.isNotEmpty) {
      result = result.where((e) {
        return (e.title ?? '')
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            (e.category ?? '')
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
      }).toList();
    }

    // Category filter
    if (_selectedCategory != 'All') {
      result =
          result.where((e) => e.category == _selectedCategory).toList();
    }

    return result;
  }

  // Total of filtered expenses
  double get _filteredTotal =>
      _filteredExpenses.fold(0.0, (sum, e) => sum + (e.amount ?? 0.0));

  // Total of all expenses
  double get _totalExpenses =>
      allExpenses.fold(0.0, (sum, e) => sum + (e.amount ?? 0.0));

  // Show add/edit expense bottom sheet
  void _showExpenseSheet({ExpenseModel? expense}) {
    final bool isEditing = expense != null;
    final TextEditingController titleController =
        TextEditingController(text: isEditing ? expense.title : '');
    final TextEditingController amountController = TextEditingController(
        text: isEditing ? expense.amount?.toStringAsFixed(0) : '');
    final TextEditingController notesController =
        TextEditingController(text: isEditing ? expense.note : '');
    String selectedCategory =
        isEditing ? (expense.category ?? 'Delivery') : 'Delivery';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  isEditing ? 'Edit Expense' : 'Add Expense',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5E1D04),
                  ),
                ),
                const SizedBox(height: 16),

                // Expense title
                _SheetLabel(label: 'Expense Title'),
                const SizedBox(height: 8),
                _SheetInputField(
                  controller: titleController,
                  hint: 'e.g. Fragrance Oils',
                  icon: Icons.receipt_outlined,
                ),
                const SizedBox(height: 12),

                // Category dropdown
                _SheetLabel(label: 'Category'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xffD08C4A),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xff5E1D04),
                      ),
                      items: _categories
                          .where((c) => c != 'All')
                          .map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setSheetState(
                            () => selectedCategory = value!);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Amount
                _SheetLabel(label: 'Amount (Rs)'),
                const SizedBox(height: 8),
                _SheetInputField(
                  controller: amountController,
                  hint: 'e.g. 5000',
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // Notes
                _SheetLabel(label: 'Notes (Optional)'),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Add any additional notes...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xffD08C4A)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty ||
                          amountController.text.isEmpty) return;

                      final double? amount =
                          double.tryParse(amountController.text);
                      if (amount == null) return;

                      Navigator.pop(context);

                      try {
                        isLoading = true;
                        setState(() {});

                        if (isEditing) {
                          // Update existing expense
                          await _expenseService.updateExpense(
                            docId: expense.docId!,
                            title: titleController.text.trim(),
                            category: selectedCategory,
                            amount: amount,
                            note: notesController.text.trim(),
                          );
                        } else {
                          // Add new expense
                          final newExpense = ExpenseModel(
                            sellerId: widget.seller.docId,
                            title: titleController.text.trim(),
                            category: selectedCategory,
                            amount: amount,
                            note: notesController.text.trim(),
                            createdAt:
                                DateTime.now().millisecondsSinceEpoch,
                          );
                          await _expenseService.addExpense(newExpense);
                        }

                        await loadExpenses();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing
                                  ? 'Expense updated'
                                  : 'Expense added',
                              style:
                                  GoogleFonts.poppins(fontSize: 13),
                            ),
                            backgroundColor: const Color(0xffD08C4A),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      } catch (e) {
                        isLoading = false;
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString(),
                              style:
                                  GoogleFonts.poppins(fontSize: 13),
                            ),
                            backgroundColor: Colors.red.shade400,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffD08C4A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isEditing ? 'Update Expense' : 'Save Expense',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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

  // Delete expense dialog
  void _showDeleteDialog(ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Expense',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${expense.title}"?',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                isLoading = true;
                setState(() {});

                await _expenseService.deleteExpense(expense.docId!);
                await loadExpenses();
              } catch (e) {
                isLoading = false;
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      e.toString(),
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xff5E1D04),
            size: 20,
          ),
        ),
        title: Text(
          'Expenses',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04),
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => _showExpenseSheet(),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xffD08C4A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+ Add',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xffD08C4A),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    children: [
                      // ── Total Expense Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff5E1D04),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Monthly Expenses',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white60,
                                    ),
                                  ),
                                  Text(
                                    'Rs ${_totalExpenses.toStringAsFixed(0)}',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${allExpenses.length} expense records',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xffD08C4A),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.poppins(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search expenses...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xffD08C4A),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFEEEEEE)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFEEEEEE)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xffD08C4A)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Category Filter
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final isSelected =
                                _selectedCategory == cat;
                            return GestureDetector(
                              onTap: () => setState(
                                  () => _selectedCategory = cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xffD08C4A)
                                      : const Color(0xFFF9F9F9),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xffD08C4A)
                                        : const Color(0xFFEEEEEE),
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Count + filtered total
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_filteredExpenses.length} Records',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff5E1D04),
                            ),
                          ),
                          Text(
                            'Total: Rs ${_filteredTotal.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xffD08C4A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // ── Expense List
                Expanded(
                  child: _filteredExpenses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 60,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No expenses found',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xffD08C4A),
                          onRefresh: loadExpenses,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                                20, 0, 20, 20),
                            itemCount: _filteredExpenses.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final expense =
                                  _filteredExpenses[index];
                              final color = _categoryColors[
                                      expense.category] ??
                                  Colors.grey;
                              final icon = _categoryIcons[
                                      expense.category] ??
                                  Icons.more_horiz_outlined;
                              return _ExpenseTile(
                                expense: expense,
                                color: color,
                                icon: icon,
                                onEdit: () => _showExpenseSheet(
                                    expense: expense),
                                onDelete: () =>
                                    _showDeleteDialog(expense),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

// ── Expense Tile
class _ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final Color color;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseTile({
    required this.expense,
    required this.color,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),

          // Expense info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff5E1D04),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        expense.category ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(expense.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                if (expense.note != null && expense.note!.isNotEmpty)
                  Text(
                    expense.note!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Amount + actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs ${expense.amount?.toStringAsFixed(0) ?? '0'}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5E1D04),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Edit',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xffD08C4A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Del',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sheet Label
class _SheetLabel extends StatelessWidget {
  final String label;
  const _SheetLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xff5E1D04),
      ),
    );
  }
}

// ── Sheet Input Field
class _SheetInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _SheetInputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey.shade400,
        ),
        prefixIcon: Icon(icon, color: const Color(0xffD08C4A), size: 20),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffD08C4A)),
        ),
      ),
    );
  }
}
