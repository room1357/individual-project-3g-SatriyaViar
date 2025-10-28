import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pemrograman_mobile/utils/category_utils.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/expense_manager.dart';
import '../utils/formater.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../Services/auth_services.dart';
import '../models/shared_expenses.dart';

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

  Future<void> _exportPDF() async {
    final pdf = pw.Document();
    final Directory dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/laporan_pengeluaran.pdf");

    final auth = AuthService();
    final sharedExpenses =
        auth.sharedExpenses
            .map(
              (s) => Expense(
                id: s.date.millisecondsSinceEpoch.toString(),
                title: s.title,
                amount: s.amount,
                category: 'Pengeluaran Bersama',
                description: 'Dibuat oleh ${s.createdBy}',
                date: s.date,
              ),
            )
            .toList();

    final allExpenses = [...widget.expenses, ...sharedExpenses];

    final categoryTotals = ExpenseManager.getTotalByCategory(
      allExpenses,
      widget.categories,
    );
    final dailyTotals = ExpenseManager.getTotalByDay(allExpenses);
    final monthlyTotals = ExpenseManager.getTotalByMonth(allExpenses);

    // Menambahkan halaman PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (context) => [
              pw.Center(
                child: pw.Text(
                  "Laporan Pengeluaran",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Rincian per kategori
              pw.Text(
                "Rincian Per Kategori:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TableHelper.fromTextArray(
                headers: ["Kategori", "Total"],
                data:
                    categoryTotals.entries
                        .map((e) => [e.key, formatRupiah(e.value)])
                        .toList(),
              ),
              pw.SizedBox(height: 20),

              // Rincian bulanan
              pw.Text(
                "Rincian Bulanan:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TableHelper.fromTextArray(
                headers: ["Bulan", "Total"],
                data:
                    monthlyTotals.entries
                        .map((e) => [formatBulan(e.key), formatRupiah(e.value)])
                        .toList(),
              ),
              pw.SizedBox(height: 20),

              // Rincian harian
              pw.Text(
                "Rincian Harian:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TableHelper.fromTextArray(
                headers: ["Tanggal", "Total"],
                data:
                    dailyTotals.entries
                        .map(
                          (e) => [formatTanggal(e.key), formatRupiah(e.value)],
                        )
                        .toList(),
              ),

              pw.SizedBox(height: 20),
              pw.Text(
                "Dibuat pada: ${DateTime.now()}",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
      ),
    );

    // Simpan file PDF
    await file.writeAsBytes(await pdf.save());

    //Cek widget aktif
    if (!mounted) return;

    // Preview PDF
    await file.writeAsBytes(await pdf.save());
    if (!mounted) return;
    _showPdfPreview(pdf);

    // Info snackbar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("✅ PDF berhasil dibuat")));
  }

  void _showPdfPreview(pw.Document pdf) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              appBar: AppBar(
                title: const Text("Preview Laporan PDF"),
                backgroundColor: Colors.deepPurple,
              ),
              body: PdfPreview(
                build: (format) => pdf.save(),
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                allowPrinting: true,
                allowSharing: true,
              ),
            ),
      ),
    );
  }

  Future<void> _exportCSV() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/laporan_pengeluaran.csv");

    final categoryTotals = ExpenseManager.getTotalByCategory(
      widget.expenses,
      widget.categories,
    );
    final dailyTotals = ExpenseManager.getTotalByDay(widget.expenses);
    final monthlyTotals = ExpenseManager.getTotalByMonth(widget.expenses);

    List<List<dynamic>> rows = [];

    // Bagian 1: Rincian Kategori
    rows.add(["Rincian Per Kategori"]);
    rows.add(["Kategori", "Total"]);
    for (var entry in categoryTotals.entries) {
      rows.add([entry.key, formatRupiah(entry.value)]);
    }

    rows.add([]); // Baris kosong pemisah

    // Bagian 2: Rincian Bulanan
    rows.add(["Rincian Bulanan"]);
    rows.add(["Bulan", "Total"]);
    for (var entry in monthlyTotals.entries) {
      rows.add([formatBulan(entry.key), formatRupiah(entry.value)]);
    }

    rows.add([]);

    // Bagian 3: Rincian Harian
    rows.add(["Rincian Harian"]);
    rows.add(["Tanggal", "Total"]);
    for (var entry in dailyTotals.entries) {
      rows.add([formatTanggal(entry.key), formatRupiah(entry.value)]);
    }

    rows.add([]);
    rows.add(["Dibuat pada", DateTime.now().toString()]);

    // Convert ke format CSV
    String csvData = const ListToCsvConverter().convert(rows);

    await file.writeAsString(csvData);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ CSV berhasil diekspor ke: ${file.path}")),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text("Ekspor sebagai PDF"),
                onTap: () {
                  Navigator.pop(context);
                  _exportPDF();
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.blue),
                title: const Text("Ekspor sebagai CSV"),
                onTap: () {
                  Navigator.pop(context);
                  _exportCSV();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data pribadi
    final personalExpenses = widget.expenses;

    // Ambil shared expenses milik user aktif dari AuthService
    final auth = AuthService();
    final sharedExpenses =
        auth.sharedExpenses.map((s) {
          return Expense(
            id: s.date.millisecondsSinceEpoch.toString(),
            title: s.title,
            amount: s.amount,
            category: 'Pengeluaran Bersama',
            description:
                'Dibuat oleh ${s.createdBy} • Anggota: ${s.members.join(', ')}',
            date: s.date,
          );
        }).toList();

    // Gabungkan semua data (pribadi + bersama)
    final allExpenses = [...personalExpenses, ...sharedExpenses];

    final categoryTotals = ExpenseManager.getTotalByCategory(
      allExpenses,
      widget.categories,
    );

    // Data sesuai toggle0
    final data =
        isDaily
            ? ExpenseManager.getTotalByDay(
              allExpenses,
            ) // Map<DateTime, double>
            : ExpenseManager.getTotalByMonth(
              allExpenses,
            ); // Map<DateTime, double>

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistik Pengeluaran"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportOptions,
            tooltip: "Eksport Data",
          ),
        ],
      ),
      body:
          categoryTotals.isEmpty
              ? const Center(child: Text("Belum ada data pengeluaran"))
              : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Total Semua
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
                          color: Colors.black.withAlpha(10),
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
                            ExpenseManager.calculateTotal(allExpenses),
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

                  // Pie Chart Distribusi Kategori
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
                                    (categoryTotals.entries.toList()..sort(
                                          (a, b) => b.value.compareTo(a.value),
                                        )) // urutkan dari total terbesar
                                        .map((entry) {
                                          final catName = entry.key;
                                          final amount = entry.value;
                                          final percentage = (amount /
                                                  ExpenseManager.calculateTotal(
                                                    widget.expenses,
                                                  ) *
                                                  100)
                                              .toStringAsFixed(1);

                                          return PieChartSectionData(
                                            color:
                                                CategoryUtils.getCategoryColor(
                                                  catName,
                                                ),
                                            value: amount,
                                            title: "$percentage%",
                                            radius: 80,
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

                          // Legend
                          Wrap(
                            spacing: 12,
                            alignment: WrapAlignment.center,
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
                  // Toggle Harian / Bulanan
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
                  // Judul List Data
                  Text(
                    isDaily ? "Pengeluaran Harian" : "Pengeluaran Bulanan",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // List Data (Harian/Bulanan)
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
