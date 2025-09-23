import 'package:flutter/material.dart';
import '../models/expense.dart';

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
      final newExpense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        description: _descriptionController.text,
      );

      widget.onAddExpense(newExpense);
      Navigator.pop(context); // tutup form
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Pengeluaran"), backgroundColor: Colors.blue,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Nama Pengeluaran"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Nama Pengeluaran wajib diisi" : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Jumlah (Rp)"),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? "Jumlah wajib diisi" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: [
                  'Makanan',
                  'Transportasi',
                  'Utilitas',
                  'Hiburan',
                  'Pendidikan'
                ]
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (val) => setState(() {
                  _selectedCategory = val!;
                }),
                decoration: const InputDecoration(labelText: "Kategori"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Tanggal: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                    ),
                  ),
                  TextButton(
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
                    child: const Text("Pilih Tanggal"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
