import '../utils/formater.dart';
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String description;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });

  // Getter untuk format tampilan mata uang
  String get formattedAmount => formatRupiah(amount);
  
  // Getter untuk format tampilan tanggal
  String get formattedDate {
    return formatTanggal(date);
  }
}