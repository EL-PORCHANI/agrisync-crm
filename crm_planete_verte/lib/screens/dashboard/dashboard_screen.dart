import 'package:flutter/material.dart';
import 'package:crm_planete_verte/services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';

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
      body: RefreshIndicator(
        onRefresh: loadDashboardData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Overview of CRM performance",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.5,
              children: [
                _buildCard("Clients", totalClients.toString(), Colors.blue, Icons.people),
                _buildCard("Orders", totalOrders.toString(), Colors.orange, Icons.shopping_cart),
                _buildCard("Revenue", "${totalRevenue.toStringAsFixed(2)} TND", Colors.green, Icons.attach_money),
                _buildCard("Unpaid", unpaidInvoices.toString(), Colors.red, Icons.warning),
                _buildCard("Visits Today", todayVisits.toString(), Colors.purple, Icons.location_on),
                _buildCard(
                  "Top Client",
                  "$topClientName\n${topClientRevenue.toStringAsFixed(0)} TND",
                  Colors.teal,
                  Icons.star,
                ),
                _buildCard(
                  "Low Stock",
                  lowStockCount.toString(),
                  Colors.deepOrange,
                  Icons.inventory,
                ),
              ],
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 24),

            const Text(
              "Sales Analytics",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              height: 280,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Monthly Revenue",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

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
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Revenue for ${revenueData.first['month']}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
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
                              maxY: revenueData
                                      .map((item) => (item['total'] as num).toDouble())
                                      .fold<double>(0, (max, value) => value > max ? value : max) *
                                  1.2,
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: revenueData.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final value = entry.value['total'] as num;
                                    return FlSpot(index.toDouble(), value.toDouble());
                                  }).toList(),
                                  isCurved: true,
                                  color: Colors.green,
                                  barWidth: 3,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.green.withValues(alpha: 0.12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(icon, size: 30, color: color),
        ],
      ),
    );
  }
}