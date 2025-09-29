import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pemrograman_mobile/screens/advanced_expense_list_screen.dart';
import 'package:pemrograman_mobile/utils/category_utils.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/expense_manager.dart';
import '../utils/formater.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;

  const StatisticsScreen({
    super.key,
    required this.expenses,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final categoryTotals = ExpenseManager.getTotalByCategory(expenses);
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.pink,
    ];

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
                  // 🔹 Total Semua dengan Gradient Card
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
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
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatRupiah(total),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Pie Chart + Legend
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
                            "Distribusi Kategori",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 220,
                            child: PieChart(
                              PieChartData(
                                sections:
                                    categoryTotals.entries
                                        .toList()
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                          final catName = entry.value.key;
                                          final amount = entry.value.value;

                                          return PieChartSectionData(
                                            color:
                                              CategoryUtils.getCategoryColor(catName),
                                            value: amount,
                                            title:
                                                "${((amount / total) * 100).toStringAsFixed(1)}%",
                                            radius: 70,
                                            titleStyle: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          );
                                        })
                                        .toList(),
                                centerSpaceRadius: 40,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 🔹 Legend warna kategori
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children:
                                categoryTotals.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      final index = entry.key;
                                      final catName = entry.value.key;
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color:
                                                  CategoryUtils.getCategoryColor(catName),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(catName),
                                        ],
                                      );
                                    })
                                    .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Rincian Per Kategori
                  const Text(
                    "Rincian per Kategori",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),
                  ),
                  const SizedBox(height: 10),

                  ...categoryTotals.entries.toList().asMap().entries.map((
                    entry,
                  ) {
                    final catName = entry.value.key;
                    final amount = entry.value.value;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child:ListTile(
                        leading: CircleAvatar(
                          backgroundColor: CategoryUtils.getCategoryColor(
                            catName,
                          ),
                          child: Icon(
                            CategoryUtils.getCategoryIcon(
                              catName,
                            ),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(catName),
                        trailing: Text(
                          formatRupiah(amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          )),
                      ),
                    );
                  }),
                ],
              ),
    );
  }
}
