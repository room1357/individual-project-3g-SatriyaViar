import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/screens/add_expanse_screen.dart';
import 'package:pemrograman_mobile/screens/edit_expanse.dart';
import 'package:pemrograman_mobile/utils/category_utils.dart';
import '../models/expense.dart';
import '../models/expense_manager.dart';
import '../models/category_manager.dart';
import '../utils/formater.dart';
import '../models/shared_expenses.dart';
import '../models/shared_expenses_manager.dart';
import '../Services/auth_services.dart';

class AdvancedExpenseListScreen extends StatefulWidget {
  const AdvancedExpenseListScreen({super.key});
  @override
  _AdvancedExpenseListScreenState createState() =>
      _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState extends State<AdvancedExpenseListScreen> {
  List<Expense> expenses = ExpenseManager.expenses;
  final categories = CategoryManager.getAllCategories();
  List<Expense> filteredExpenses = [];
  String selectedCategory = 'Semua';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllExpenses(); // 🔹 load semua data (personal + shared)
  }

  // 🔹 fungsi baru untuk meload semua data
  Future<void> _loadAllExpenses() async {
    // 🔹 1. Ambil user aktif lewat AuthService
    final auth = AuthService();
    final currentUser = await auth.getCurrentUser();
    if (currentUser == null) {
      print('⚠️ Tidak ada user aktif, tidak bisa memuat shared expenses.');
      return;
    }

    // 🔹 2. Ambil expense pribadi (kode lama)
    final personalExpenses = ExpenseManager.expenses;

    //Load ulang shared expenses untuk user aktif
    await auth.loadUserSharedExpenses();
    final sharedExpenses = auth.sharedExpenses;

    print('✅ Total personal: ${personalExpenses.length}');
    print('✅ Total shared: ${sharedExpenses.length}');

    // 🔹 4. Konversi SharedExpense → Expense
    final sharedConverted =
        sharedExpenses.map((s) {
          return Expense(
            id: s.date.millisecondsSinceEpoch.toString(), // unik
            title: s.title,
            amount: s.amount,
            category: 'Pengeluaran Bersama',
            description:
                'Dibuat oleh ${s.createdBy} • Anggota: ${s.members.join(', ')}',
            date: s.date,
          );
        }).toList();

    setState(() {
      expenses = [...personalExpenses, ...sharedConverted];
      filteredExpenses = expenses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran Advanced'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: _loadAllExpenses, // 🔹 tombol refresh manual
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Cari pengeluaran...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _filterExpenses();
              },
            ),
          ),

          // Category filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ...[
                  'Semua',
                  ...categories.map((c) => c.name).toSet(),
                  'Pengeluaran Bersama', // 🔹 tambahan kategori khusus
                ].map((category) {
                  final isSelected = selectedCategory == category;

                  final categoryColor =
                      category == 'Semua'
                          ? Colors.grey
                          : CategoryUtils.getCategoryColor(category);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: categoryColor,
                      backgroundColor: categoryColor.withAlpha(236),
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = category;
                          _filterExpenses();
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Statistics summary
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total',
                  formatRupiah(ExpenseManager.calculateTotal(filteredExpenses)),
                ),
                _buildStatCard('Jumlah', '${filteredExpenses.length} item'),
                _buildStatCard(
                  'Rata-rata',
                  formatRupiah(
                    ExpenseManager.calculateAverage(filteredExpenses),
                  ),
                ),
              ],
            ),
          ),

          // Expense list
          Expanded(
            child:
                filteredExpenses.isEmpty
                    ? const Center(
                      child: Text('Tidak ada pengeluaran ditemukan'),
                    )
                    : ListView.builder(
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: CategoryUtils.getCategoryColor(
                                expense.category,
                              ),
                              child: Icon(
                                CategoryUtils.getCategoryIcon(expense.category),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(expense.title),
                            subtitle: Text(
                              '${expense.category} • ${expense.formattedDate}',
                            ),
                            trailing: Text(
                              expense.formattedAmount,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () => _showExpenseDetails(context, expense),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AddExpenseScreen(
                    onAddExpense: (newExpense) {
                      setState(() {
                        expenses.add(newExpense);
                        _filterExpenses();
                      });
                    },
                  ),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _filterExpenses() {
    setState(() {
      filteredExpenses =
          expenses.where((expense) {
            bool matchesSearch =
                searchController.text.isEmpty ||
                expense.title.toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ) ||
                expense.description.toLowerCase().contains(
                  searchController.text.toLowerCase(),
                );

            bool matchesCategory =
                selectedCategory == 'Semua' ||
                expense.category == selectedCategory;

            return matchesSearch && matchesCategory;
          }).toList();
    });
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.indigo.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      expense.title.toUpperCase(),
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontFamily: 'Lucida Sans',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontFamily: 'Lucida Sans',
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(
                            Icons.attach_money,
                            "Jumlah",
                            expense.formattedAmount,
                            valueColor: Colors.green,
                          ),
                          const Divider(),
                          _infoRow(
                            Icons.category,
                            "Kategori",
                            expense.category,
                            valueColor: Colors.blueGrey,
                          ),
                          const Divider(),
                          _infoRow(
                            Icons.date_range,
                            "Tanggal",
                            expense.formattedDate,
                            valueColor: Colors.deepPurple,
                          ),
                          const Divider(),
                          _infoRow(
                            Icons.description,
                            "Deskripsi",
                            expense.description,
                            valueColor: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => EditExpenseScreen(
                                    expense: expense,
                                    onEditExpense: (updatedExpense) {
                                      setState(() {
                                        final index = expenses.indexWhere(
                                          (e) => e.id == expense.id,
                                        );
                                        if (index != -1) {
                                          expenses[index] = updatedExpense;
                                        }
                                      });
                                    },
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Edit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text("Tutup"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.deepPurple, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Lucida Sans',
                fontSize: 15,
                color: Colors.black87,
              ),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
