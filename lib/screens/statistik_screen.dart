import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pemrograman_mobile/utils/category_utils.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/expense_manager.dart';
import '../utils/formater.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  final List<Expense> expenses;
  final List<Category> categories;

  const StatisticsScreen({
    super.key,
    required this.expenses,
    required this.categories,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool isDaily = true; // toggle harian/bulanan

  @override
  Widget build(BuildContext context) {
    final categoryTotals = ExpenseManager.getTotalByCategory(widget.expenses, widget.categories);
    final averagedaily = ExpenseManager.getAverageDaily(widget.expenses);

    // 🔹 Data sesuai toggle
    final data =
        isDaily
            ? ExpenseManager.getTotalByDay(
              widget.expenses,
            ) // Map<DateTime, double>
            : ExpenseManager.getTotalByMonth(
              widget.expenses,
            ); // Map<DateTime, double>

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistik Pengeluaran"),
        backgroundColor: Colors.blue,
      ),
      body:
          categoryTotals.isEmpty
              ? const Center(child: Text("Belum ada data pengeluaran"))
              : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 🔹 Total Semua
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.deepPurpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Total Pengeluaran",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Lucida Sans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatRupiah(
                            ExpenseManager.calculateTotal(widget.expenses),
                          ),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 🔹 Pie Chart Distribusi Kategori
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text(
                            "Distribusi Pengeluaran per Kategori",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 220,
                            child: PieChart(
                              PieChartData(
                                sections:
                                    categoryTotals.entries.map((entry) {
                                      final catName = entry.key;
                                      final amount = entry.value;
                                      final percentage = (amount /
                                              ExpenseManager.calculateTotal(
                                                widget.expenses,
                                              ) *
                                              100)
                                          .toStringAsFixed(1);

                                      return PieChartSectionData(
                                        color: CategoryUtils.getCategoryColor(
                                          catName,
                                        ),
                                        value: amount,
                                        title: "$percentage%",
                                        radius: 70,
                                        titleStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      );
                                    }).toList(),
                                centerSpaceRadius: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 🔹 Legend
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children:
                                categoryTotals.entries.map((entry) {
                                  final catName = entry.key;
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: CategoryUtils.getCategoryColor(
                                            catName,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(catName),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Divider(height: 20, color: Colors.black, thickness: 2),
                  const SizedBox(height: 20),
                  // 🔹 Toggle Harian / Bulanan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Bulanan",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Lucida Sans",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: isDaily,
                        onChanged: (val) {
                          setState(() {
                            isDaily = val;
                          });
                        },
                      ),
                      const Text(
                        "Harian",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Lucida Sans",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  // 🔹 Judul List Data
                  Text(
                    isDaily ? "Pengeluaran Harian" : "Pengeluaran Bulanan",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // 🔹 List Data (Harian/Bulanan)
                  ...data.entries.map((entry) {
                    final label =
                        isDaily
                            ? formatTanggal(entry.key)
                            : formatBulan(entry.key);
                    final amount = entry.value;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(
                          isDaily ? Icons.calendar_today : Icons.calendar_month,
                          color: Colors.blue,
                        ),
                        title: Text(
                          label,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          formatRupiah(amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
    );
  }
}
