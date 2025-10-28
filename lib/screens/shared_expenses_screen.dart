import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shared_expenses.dart';
import '../Services/auth_services.dart';

class SharedExpensesScreen extends StatefulWidget {
  final UserAccount currentUser;

  const SharedExpensesScreen({super.key, required this.currentUser});

  @override
  State<SharedExpensesScreen> createState() => _SharedExpensesScreenState();
}

class _SharedExpensesScreenState extends State<SharedExpensesScreen> {
  List<SharedExpense> _allExpenses = [];
  List<SharedExpense> _visibleExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  /// 🔹 Muat semua data pengeluaran dari SharedPreferences
  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('shared_expenses');

    if (data != null) {
      final decoded = jsonDecode(data) as List;
      _allExpenses = decoded.map((e) => SharedExpense.fromMap(e)).toList();

      // Filter sesuai user yang login
      _visibleExpenses = _allExpenses.where((e) {
        return e.createdBy == widget.currentUser.username ||
            e.members.contains(widget.currentUser.username);
      }).toList();
    }

    setState(() {});
  }

  /// 🔹 Simpan semua data ke SharedPreferences
  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'shared_expenses',
      jsonEncode(_allExpenses.map((e) => e.toMap()).toList()),
    );
  }

  /// 🔹 Form untuk menambah pengeluaran baru
  void _showAddExpenseForm() async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final membersController = TextEditingController();

    final authService = AuthService();
    await authService.loadData();
    final allUsers = authService.getAllUsers();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Tambah Shared Expense',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildTextField(titleController, 'Judul'),
                _buildTextField(
                  amountController,
                  'Jumlah (Rp)',
                  keyboardType: TextInputType.number,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Dibuat oleh: ${widget.currentUser.username}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),

                _buildTextField(
                  membersController,
                  'Anggota (pisahkan dengan koma)',
                  hintText: allUsers.isNotEmpty
                      ? 'Contoh: ${allUsers.map((u) => u.username).where((u) => u != widget.currentUser.username).take(3).join(', ')}'
                      : 'Belum ada user lain',
                ),

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        amountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Judul dan jumlah wajib diisi!'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    // 🔹 Pisahkan nama anggota (kalau diisi)
                    final List<String> members =
                        membersController.text.isNotEmpty
                            ? List<String>.from(
                                membersController.text
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty),
                              )
                            : <String>[];

                    final newExpense = SharedExpense(
                      title: titleController.text.trim(),
                      amount: double.tryParse(amountController.text) ?? 0,
                      createdBy: widget.currentUser.username,
                      members: members,
                      date: DateTime.now(),
                    );

                    setState(() {
                      _allExpenses.add(newExpense);

                      // Tampilkan hanya kalau user termasuk di dalamnya
                      if (newExpense.createdBy ==
                              widget.currentUser.username ||
                          newExpense.members
                              .contains(widget.currentUser.username)) {
                        _visibleExpenses.add(newExpense);
                      }
                    });

                    _saveExpenses();
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data berhasil ditambahkan!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Simpan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          filled: true,
          fillColor: Colors.blue.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  double get totalExpenses =>
      _visibleExpenses.fold(0, (sum, e) => sum + e.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Expenses'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _visibleExpenses.isEmpty
            ? const Center(
                child: Text(
                  'Belum ada data pengeluaran bersama',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            : ListView(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Pengeluaran Bersama',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Rp ${totalExpenses.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${_visibleExpenses.length} transaksi',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._visibleExpenses.map(
                    (e) => Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        title: Text(
                          e.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rp ${e.amount.toStringAsFixed(0)}'),
                            Text('Dibuat oleh: ${e.createdBy}'),
                            if (e.members.isNotEmpty)
                              Text(
                                'Per orang: Rp ${(e.amount / (e.members.length + 1)).toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            const SizedBox(height: 4),
                            Wrap(
                              children: e.members
                                  .map(
                                    (m) => Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4.0),
                                      child: Chip(
                                        label: Text(m),
                                        backgroundColor: Colors.blue.shade50,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '${e.date.day}/${e.date.month}/${e.date.year}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseForm,
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
