import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DateFormatter {
  // Format a date as "Just now" (< 1 min), "X minutes ago", etc.
  static String getTimeAgo(DateTime date) {
    return timeago.format(date);
  }
  
  // Format a date as "Jan 1, 2023"
  static String getShortDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }
  
  // Format a date as "January 1, 2023"
  static String getLongDate(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }
  
  // Format a date as "Jan 1, 2023, 12:30 PM"
  static String getDateWithTime(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }
}