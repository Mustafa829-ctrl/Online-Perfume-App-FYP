import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_perfume_app_fyp/models/seller_model.dart';

import '../../../services/analytical_service.dart';

class SellerAnalyticsScreen extends StatefulWidget {
  final SellerModel seller;
  const SellerAnalyticsScreen({super.key, required this.seller});

  @override
  State<SellerAnalyticsScreen> createState() => _SellerAnalyticsScreenState();
}

class _SellerAnalyticsScreenState extends State<SellerAnalyticsScreen> {
  final AnalyticsService _analytics = AnalyticsService();

  bool isLoading = false;
  String _selectedPeriod = 'Weekly';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];
  String _selectedPLPeriod = 'Monthly';
  final List<String> _plPeriods = ['Daily', 'Monthly', 'Yearly'];

  // Stats
  double totalSales = 0;
  int totalOrders = 0;
  double totalExpenses = 0;
  double netProfit = 0;

  // P&L
  Map<String, Map<String, dynamic>> plData = {
    'Daily':   {'revenue': 0, 'expenses': 0, 'profit': 0, 'isProfit': true, 'percentage': '0%'},
    'Monthly': {'revenue': 0, 'expenses': 0, 'profit': 0, 'isProfit': true, 'percentage': '0%'},
    'Yearly':  {'revenue': 0, 'expenses': 0, 'profit': 0, 'isProfit': true, 'percentage': '0%'},
  };

  List<Map<String, dynamic>> topProducts = [];

  // Chart data
  Map<String, List<Map<String, dynamic>>> salesChartData = {
    'Daily': [
      {'label': '9AM', 'amount': 0}, {'label': '11AM', 'amount': 0},
      {'label': '1PM', 'amount': 0}, {'label': '3PM',  'amount': 0},
      {'label': '5PM', 'amount': 0}, {'label': '7PM',  'amount': 0},
    ],
    'Weekly': [
      {'label': 'Mon', 'amount': 0}, {'label': 'Tue', 'amount': 0},
      {'label': 'Wed', 'amount': 0}, {'label': 'Thu', 'amount': 0},
      {'label': 'Fri', 'amount': 0}, {'label': 'Sat', 'amount': 0},
      {'label': 'Sun', 'amount': 0},
    ],
    'Monthly': [
      {'label': 'Jan', 'amount': 0}, {'label': 'Feb', 'amount': 0},
      {'label': 'Mar', 'amount': 0}, {'label': 'Apr', 'amount': 0},
      {'label': 'May', 'amount': 0}, {'label': 'Jun', 'amount': 0},
    ],
  };

  @override
  void initState() {
    super.initState();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    try {
      setState(() => isLoading = true);
      final sellerId = widget.seller.docId ?? '';

      final results = await Future.wait([
        _analytics.getMonthlySales(sellerId),
        _analytics.getWeeklySales(sellerId),
        _analytics.getDailySales(sellerId),
        _analytics.getTopSellingProducts(sellerId),
        _analytics.getProfitLossSummary(sellerId),
        _analytics.getYearlyProfitLoss(sellerId),
      ]);

      totalSales    = (results[0] as double);
      totalOrders   = await _getTotalOrders(sellerId);
      totalExpenses = (results[4] as Map)['totalExpenses'] as double;
      netProfit     = (results[4] as Map)['profit'] as double;

      // Top products
      final rawProducts = results[3] as List<Map<String, dynamic>>;
      topProducts = rawProducts.map((data) {
        final sold  = (data['totalSold'] as num?)?.toInt() ?? 0;
        final price = (data['price'] as num?)?.toDouble() ?? 0.0;
        return {
          'name':     data['name'] ?? '',
          'category': data['category'] ?? '',
          'sold':     sold,
          'revenue':  'Rs ${(sold * price).toStringAsFixed(0)}',
        };
      }).toList();

      // Weekly chart data
      await _buildWeeklyChart(sellerId);

      // P&L data
      final daily     = results[2] as double;
      final monthly   = results[0] as double;
      final yearly    = (results[5] as Map)['totalSales'] as double;
      final yearlyExp = (results[5] as Map)['totalExpenses'] as double;

      plData = {
        'Daily':   _buildPL(daily,   totalExpenses),
        'Monthly': _buildPL(monthly, totalExpenses),
        'Yearly':  _buildPL(yearly,  yearlyExp),
      };

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(), style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  /// Get total delivered orders count
  Future<int> _getTotalOrders(String sellerId) async {
    try {
      final orders = await _analytics.getTopSellingProducts(sellerId, limit: 1000);
      return orders.length;
    } catch (_) {
      return 0;
    }
  }

  /// Build weekly chart from Firestore
  Future<void> _buildWeeklyChart(String sellerId) async {
    try {
      final now     = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      Map<int, int> daySales = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

      final startMillis = DateTime(weekAgo.year, weekAgo.month, weekAgo.day)
          .millisecondsSinceEpoch;

      // removed _ prefix
      final snap = await _analytics.getOrdersFromDate(sellerId, startMillis);

      for (var data in snap) {
        final deliveredAt = data['deliveredAt'];
        if (deliveredAt != null) {
          final date    = DateTime.fromMillisecondsSinceEpoch(deliveredAt as int);
          final weekday = date.weekday - 1; // 0=Mon
          daySales[weekday] =
              (daySales[weekday] ?? 0) + ((data['amount'] as num?)?.toInt() ?? 0);
        }
      }

      salesChartData['Weekly'] = [
        {'label': 'Mon', 'amount': daySales[0]},
        {'label': 'Tue', 'amount': daySales[1]},
        {'label': 'Wed', 'amount': daySales[2]},
        {'label': 'Thu', 'amount': daySales[3]},
        {'label': 'Fri', 'amount': daySales[4]},
        {'label': 'Sat', 'amount': daySales[5]},
        {'label': 'Sun', 'amount': daySales[6]},
      ];
    } catch (_) {}
  }

  /// Build P&L map
  Map<String, dynamic> _buildPL(double revenue, double expense) {
    final profit   = revenue - expense;
    final isProfit = profit >= 0;
    final pct = revenue == 0
        ? '0%'
        : '${isProfit ? '+' : '-'}${((profit.abs() / revenue) * 100).toStringAsFixed(1)}%';
    return {
      'revenue':    revenue.toInt(),
      'expenses':   expense.toInt(),
      'profit':     profit.abs().toInt(),
      'isProfit':   isProfit,
      'percentage': pct,
    };
  }

  double _getMaxAmount(List<Map<String, dynamic>> data) {
    double max = 0;
    for (var item in data) {
      if ((item['amount'] as num).toDouble() > max) {
        max = (item['amount'] as num).toDouble();
      }
    }
    return max == 0 ? 1 : max;
  }

  String _formatAmount(int amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000)   return '${(amount / 1000).toStringAsFixed(0)},000';
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    final currentSalesData = salesChartData[_selectedPeriod]!;
    final currentPL        = plData[_selectedPLPeriod]!;
    final maxAmount        = _getMaxAmount(currentSalesData);

    return isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xffD08C4A)))
        : RefreshIndicator(
            color: const Color(0xffD08C4A),
            onRefresh: loadAnalytics,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Stats Cards
                  Row(children: [
                    Expanded(child: _StatCard(label: 'Total Sales',    value: 'Rs ${totalSales.toStringAsFixed(0)}',    icon: Icons.trending_up,                    bgColor: const Color(0xFFFFF3CD), iconColor: const Color(0xffD08C4A))),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: 'Total Orders',   value: '$totalOrders',                           icon: Icons.shopping_bag_outlined,           bgColor: const Color(0xFFE8F5E9), iconColor: const Color(0xff66BB6A))),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _StatCard(label: 'Total Expenses', value: 'Rs ${totalExpenses.toStringAsFixed(0)}', icon: Icons.account_balance_wallet_outlined, bgColor: const Color(0xFFFCE4EC), iconColor: const Color(0xffEF5350))),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: 'Net Profit',     value: 'Rs ${netProfit.toStringAsFixed(0)}',     icon: Icons.monetization_on_outlined,        bgColor: const Color(0xFFE3F2FD), iconColor: const Color(0xff42A5F5))),
                  ]),
                  const SizedBox(height: 24),

                  // Revenue Chart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Text('Revenue Analytics', style: GoogleFonts.playfairDisplay(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      _PeriodSelector(periods: _periods, selected: _selectedPeriod, activeColor: const Color(0xffD08C4A), onSelect: (p) => setState(() => _selectedPeriod = p)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ChartCard(data: currentSalesData, maxAmount: maxAmount, selectedPeriod: _selectedPeriod),
                  const SizedBox(height: 24),

                  // Profit & Loss
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Text('Profit & Loss', style: GoogleFonts.playfairDisplay(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      _PeriodSelector(periods: _plPeriods, selected: _selectedPLPeriod, activeColor: const Color(0xff5E1D04), onSelect: (p) => setState(() => _selectedPLPeriod = p)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEEEEEE))),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Total Net Profit', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
                          Text('Rs ${_formatAmount(currentPL['profit'] as int)}', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04))),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: (currentPL['isProfit'] as bool) ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC), borderRadius: BorderRadius.circular(20)),
                          child: Text(currentPL['percentage'] as String, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: (currentPL['isProfit'] as bool) ? const Color(0xff66BB6A) : const Color(0xffEF5350))),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 12),
                      _PLRow(label: 'Total Revenue',  value: 'Rs ${_formatAmount(currentPL['revenue'] as int)}',
                          color: const Color(0xff66BB6A),
                          icon: Icons.arrow_upward),
                      const SizedBox(height: 10),
                      _PLRow(label: 'Total Expenses', value: 'Rs ${_formatAmount(currentPL['expenses'] as int)}',
                          color: const Color(0xffEF5350),
                          icon: Icons.arrow_downward),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Top Selling Products
                  Text('Top Selling Products', style: GoogleFonts.playfairDisplay(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5E1D04))),
                  const SizedBox(height: 12),
                  topProducts.isEmpty
                      ? Center(child: Padding(padding: const EdgeInsets.all(20),
                      child: Text('No products yet', style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade400))))
                      : Column(children: topProducts.asMap().entries.map((e) => _TopProductTile(rank: e.key + 1, product: e.value)).toList()),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
  }
}

// ── Widgets

class _PeriodSelector extends StatelessWidget {
  final List<String> periods;
  final String selected;
  final Color activeColor;
  final Function(String) onSelect;
  const _PeriodSelector({required this.periods, required this.selected, required this.activeColor, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Row(mainAxisSize: MainAxisSize.min, children: periods.map((period) {
        final isSelected = selected == period;
        return GestureDetector(onTap: () => onSelect(period), child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(color: isSelected ? activeColor : Colors.transparent, borderRadius: BorderRadius.circular(8)),
          child: Text(period, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.grey.shade500)),
        ));
      }).toList()),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final double maxAmount;
  final String selectedPeriod;
  const _ChartCard({required this.data, required this.maxAmount, required this.selectedPeriod});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Column(children: [
        SizedBox(height: 140, child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: data.map((d) {
          final ratio = (d['amount'] as num).toDouble() / maxAmount;
          final isHighest = (d['amount'] as num).toDouble() == maxAmount;
          return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (isHighest) Text('Rs ${((d['amount'] as num) / 1000).toStringAsFixed(1)}k', style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xffD08C4A), fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Container(width: 26, height: ratio == 0 ? 4 : 110 * ratio, decoration: BoxDecoration(color: isHighest ? const Color(0xffD08C4A) : const Color(0xFFFCE4EC), borderRadius: BorderRadius.circular(6))),
          ]);
        }).toList())),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: data.map((d) => Text(d['label'], style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500))).toList()),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color bgColor, iconColor;
  const _StatCard({required this.label, required this.value, required this.icon, required this.bgColor, required this.iconColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, color: iconColor, size: 22), const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xff5E1D04)), overflow: TextOverflow.ellipsis),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600)),
        ])),
      ]),
    );
  }
}

class _PLRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _PLRow({required this.label, required this.value, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Container(width: 28, height: 28, decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16)),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade600)),
      ]),
      Text(value, style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color)),
    ]);
  }
}

class _TopProductTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> product;
  const _TopProductTile({required this.rank, required this.product});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Row(children: [
        Container(width: 32, height: 32,
          decoration: BoxDecoration(
              color: rank == 1 ? const Color(0xffD08C4A) :
              rank == 2 ? const Color(0xFFB0BEC5) :
              rank == 3 ? const Color(0xFFBCAAA4) :
              const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
              border: rank > 3 ? Border.all(color: const Color(0xFFEEEEEE)) : null),
          child: Center(child: Text('#$rank', style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: rank <= 3 ? Colors.white : Colors.grey.shade500)))),
        const SizedBox(width: 12),
        Container(width: 42, height: 42, decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.local_florist_outlined,
                color: Color(0xffD08C4A), size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product['name'], style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: const Color(0xff5E1D04))),
        ])),
        Text(product['revenue'], style: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.bold,
            color: const Color(0xff5E1D04))),
      ]),
    );
  }
}
