import 'package:intl/intl.dart';

extension DateTimeFormat on DateTime {
  String toIsoformatString() => toIso8601String();
  
  String formatYMD() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  String formatFull() {
    return DateFormat('MMM dd, yyyy').format(this);
  }
}
