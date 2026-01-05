import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }

  static String formatYear(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return date.year.toString();
    } catch (_) {
      return dateString;
    }
  }
}
