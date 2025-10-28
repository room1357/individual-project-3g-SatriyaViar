import '../utils/formater.dart';

class Income {
  final String id;
  final String title;
  final double amount;
  final String source;
  final DateTime date;
  final String description;

  Income({
    required this.id,
    required this.title,
    required this.amount,
    required this.source,
    required this.date,
    required this.description,
  });

  // Format tampilan rupiah
  String get formattedAmount => formatRupiah(amount);

  // Format tampilan tanggal
  String get formattedDate => formatTanggal(date);
}
