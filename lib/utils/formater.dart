import 'package:intl/intl.dart';

String formatRupiah(double value, {int decimalDigit = 0}){
  final formater = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: decimalDigit
  );
  return formater.format(value);
}

String formatTanggal(DateTime value){
  final formater = DateFormat('dd-MM-yyyy');
  return formater.format(value);
}