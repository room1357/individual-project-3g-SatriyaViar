import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/utils/formater.dart';
import '../models/expense.dart';
import '../models/category_manager.dart';

class AddExpenseScreen extends StatefulWidget {
  final Function(Expense) onAddExpense;

  const AddExpenseScreen({super.key, required this.onAddExpense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Makanan';
  DateTime _selectedDate = DateTime.now();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      try {
        print("=== SUBMIT DEBUG ===");
        print("Title: ${_titleController.text}");
        print("Amount: ${_amountController.text}");
        print("Category: $_selectedCategory");
        print("Date: $_selectedDate");
        print("Description: ${_descriptionController.text}");

        final newExpense = Expense(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          amount: double.parse(_amountController.text),
          category: _selectedCategory,
          date: _selectedDate,
          description: _descriptionController.text,
        );

        print("✅ New expense created: $newExpense");

        widget.onAddExpense(newExpense);
        Navigator.pop(context);
      } catch (e, stack) {
        print("❌ Error saat submit: $e");
        print(stack);
      }
    } else {
      print("⚠️ Form tidak valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tambah Pengeluaran",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Input Nama Pengeluaran
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Nama Pengeluaran",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: const Icon(Icons.edit),
                ),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? "Nama Pengeluaran wajib diisi"
                            : null,
              ),
              const SizedBox(height: 16),
              // Input Jumlah
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: "Jumlah (Rp)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Jumlah wajib diisi";
                  }
                  if (double.tryParse(val) == null) {
                    return "Jumlah harus berupa angka";
                  }
                  if (double.parse(val) <= 0) {
                    return "Jumlah harus lebih besar dari 0";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Input Deskripsi
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Deskripsi",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: const Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Dropdown Kategori
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items:
                    CategoryManager.getAllCategories()
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat.name,
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                Text(cat.name),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    (val) => setState(() {
                      _selectedCategory = val!;
                    }),
                decoration: InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: const Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),

              // Date Picker
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Tanggal: ${formatTanggal(_selectedDate)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() => _selectedDate = pickedDate);
                      }
                    },
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text("Pilih Tanggal"),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 3,
                  ),
                  child: const Text(
                    "Simpan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
