import 'package:intl/intl.dart';

class DateUtilities {
  static String formatDateTime(DateTime dateTime) {
    final DateFormat dateFormatter =
        DateFormat('dd MMM yyyy'); // Example: 18 Dec 2024
    final DateFormat timeFormatter = DateFormat('hh:mm a'); // Example: 02:30 PM

    String formattedDate = dateFormatter.format(dateTime);
    String formattedTime = timeFormatter.format(dateTime);

    return "$formattedDate at $formattedTime";
  }
}
