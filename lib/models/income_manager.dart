import 'income.dart';

class IncomeManager {
  static List<Income> incomes = [
    Income(
      id: '1',
      title: 'Gaji Bulanan',
      amount: 5000000,
      source: 'Pekerjaan Utama',
      date: DateTime(2024, 9, 1),
      description: 'Gaji bulan September',
    ),
    Income(
      id: '2',
      title: 'Freelance Project',
      amount: 1500000,
      source: 'Proyek Website',
      date: DateTime(2024, 9, 10),
      description: 'Pendapatan dari proyek freelance',
    ),
    Income(
      id: '3',
      title: 'Hasil Jual Barang',
      amount: 300000,
      source: 'Marketplace',
      date: DateTime(2024, 9, 15),
      description: 'Jual headset bekas',
    ),
  ];

  // 1. Total seluruh income
  static double calculateTotal(List<Income> incomes) {
    return incomes.fold(0, (sum, income) => sum + income.amount);
  }

  // 2. Total income per bulan
  static Map<DateTime, double> getTotalByMonth(List<Income> incomes) {
    final Map<DateTime, double> totals = {};
    for (var income in incomes) {
      final monthKey = DateTime(income.date.year, income.date.month);
      totals[monthKey] = (totals[monthKey] ?? 0) + income.amount;
    }
    return totals;
  }

  // 3. Ambil semua income
  static List<Income> getAllIncomes() {
    return List.unmodifiable(incomes);
  }

  // 4. Mencari income berdasarkan kata kunci
  static List<Income> searchIncomes(List<Income> incomes, String keyword) {
    String lowerKeyword = keyword.toLowerCase();
    return incomes
        .where(
          (income) =>
              income.title.toLowerCase().contains(lowerKeyword) ||
              income.source.toLowerCase().contains(lowerKeyword) ||
              income.description.toLowerCase().contains(lowerKeyword),
        )
        .toList();
  }
}
