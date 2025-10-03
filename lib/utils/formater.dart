import 'package:intl/intl.dart';

String formatRupiah(double value, {double decimalDigit = 0}){
  final formater = NumberFormat.currency(
    locale: 'id',  
    symbol: 'Rp ',
    decimalDigits: 0
  );
  return formater.format(value);
}

String formatTanggal(DateTime value){
  var formater = DateFormat('dd-MMM-yyyy');
  return formater.format(value);  
}

String formatBulan(DateTime value) {
  var formatter = DateFormat('MMMM yyyy'); // contoh: "Oktober 2025"
  return formatter.format(value);
}
