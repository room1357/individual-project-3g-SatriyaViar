import 'package:intl/intl.dart';

String formatRupiah(double value, {int decimalDigit = 0}){
  final formater = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: decimalDigit
  );
  return formater.format(value);
}

// String formatTanggal(DateTime value){
//   final formater = DateFormat('dd-mm-yyyy');
//   return formater.format(value);
// }

String formatTanggal(DateTime value){
  var formater = DateFormat('dd-MMM-yyyy');
  return formater.format(value);  
}