import 'package:flutter/material.dart';
import 'package:crm_planete_verte/services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_kpi_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final db = DatabaseService.instance;

  int totalClients = 0;
  int totalOrders = 0;
  double totalRevenue = 0;
  int unpaidInvoices = 0;
  int todayVisits = 0;
  String topClientName = "";
  double topClientRevenue = 0;
  int lowStockCount = 0;

  List<Map<String, dynamic>> revenueData = [];

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    await db.refreshInvoiceStatuses();

    final loadedTotalClients = await db.getTotalClients();
    final loadedTotalOrders = await db.getTotalOrders();
    final loadedTotalRevenue = await db.getTotalRevenue();

    final unpaidList = await db.getUnpaidInvoices();
    final loadedUnpaidInvoices = unpaidList.length;

    final loadedTodayVisits = await db.getTodayVisits();
    final loadedRevenueData = await db.getRevenueByMonth();
    final topClient = await db.getTopClient();
    final loadedLowStockCount = await db.getLowStockCount();

    String loadedTopClientName = "";
    double loadedTopClientRevenue = 0;

    if (topClient != null) {
      loadedTopClientName = topClient['name'] ?? "";
      loadedTopClientRevenue = (topClient['total'] as num?)?.toDouble() ?? 0;
    }

    if (!mounted) return;

    setState(() {
      totalClients = loadedTotalClients;
      totalOrders = loadedTotalOrders;
      totalRevenue = loadedTotalRevenue;
      unpaidInvoices = loadedUnpaidInvoices;
      todayVisits = loadedTodayVisits;
      revenueData = loadedRevenueData;
      topClientName = loadedTopClientName;
      topClientRevenue = loadedTopClientRevenue;
      lowStockCount = loadedLowStockCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: loadDashboardData,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            AppMotion.fadeSlide(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepGreen.withValues(alpha: 0.12),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.insights,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Operational Dashboard',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Local CRM indicators for field activity',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.76),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                int crossAxisCount;
                double childAspectRatio;

                if (maxWidth >= 950) {
                  crossAxisCount = 4;
                  childAspectRatio = 2.6;
                } else if (maxWidth >= 620) {
                  crossAxisCount = 2;
                  childAspectRatio = 2.15;
                } else {
                  crossAxisCount = 1;
                  childAspectRatio = 3.1;
                }

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildCard(
                      "Clients",
                      totalClients.toString(),
                      AppColors.blue,
                      Icons.people,
                    ),
                    _buildCard(
                      "Orders",
                      totalOrders.toString(),
                      AppColors.amber,
                      Icons.shopping_cart,
                    ),
                    _buildCard(
                      "Revenue",
                      "${totalRevenue.toStringAsFixed(2)} TND",
                      AppColors.olive,
                      Icons.attach_money,
                    ),
                    _buildCard(
                      "Unpaid",
                      unpaidInvoices.toString(),
                      AppColors.red,
                      Icons.warning,
                    ),
                    _buildCard(
                      "Visits Today",
                      todayVisits.toString(),
                      AppColors.purple,
                      Icons.location_on,
                    ),
                    _buildCard(
                      "Top Client",
                      topClientName.isEmpty
                          ? "No data"
                          : "$topClientName\n${topClientRevenue.toStringAsFixed(0)} TND",
                      AppColors.teal,
                      Icons.star,
                    ),
                    _buildCard(
                      "Low Stock",
                      lowStockCount.toString(),
                      AppColors.amber,
                      Icons.inventory,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              "Sales Analytics",
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: AppSpacing.md),

            SizedBox(
              height: 280,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Monthly Revenue",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      Expanded(
                        child: revenueData.isEmpty
                            ? const Center(child: Text("No revenue data yet"))
                            : revenueData.length == 1
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${(revenueData.first['total'] as num).toDouble().toStringAsFixed(2)} TND",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(color: AppColors.olive),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      "Revenue for ${revenueData.first['month']}",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              )
                            : LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: revenueData.length > 1
                                      ? (revenueData.length - 1).toDouble()
                                      : 1,
                                  minY: 0,
                                  maxY:
                                      revenueData
                                          .map(
                                            (item) => (item['total'] as num)
                                                .toDouble(),
                                          )
                                          .fold<double>(
                                            0,
                                            (max, value) =>
                                                value > max ? value : max,
                                          ) *
                                      1.2,
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (_) => FlLine(
                                      color: AppColors.border,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  titlesData: FlTitlesData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: revenueData.asMap().entries.map((
                                        entry,
                                      ) {
                                        final index = entry.key;
                                        final value =
                                            entry.value['total'] as num;
                                        return FlSpot(
                                          index.toDouble(),
                                          value.toDouble(),
                                        );
                                      }).toList(),
                                      isCurved: true,
                                      color: AppColors.olive,
                                      barWidth: 3,
                                      dotData: FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: AppColors.olive.withValues(
                                          alpha: 0.12,
                                        ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String value, Color color, IconData icon) {
    return AppKpiCard(title: title, value: value, icon: icon, color: color);
  }
}
