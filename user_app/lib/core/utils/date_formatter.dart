import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DateFormatter {
  DateFormatter._();

  static void init() {
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    timeago.defaultLocale = 'ar';
  }

  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 5) return 'الآن';
    if (diff.inSeconds < 60) return 'منذ ${diff.inSeconds} ثانية';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
    if (diff.inDays < 365) return 'منذ ${(diff.inDays / 30).floor()} شهر';
    return 'منذ ${(diff.inDays / 365).floor()} سنة';
  }

  static String timeagoFormatted(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'ar');
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat.yMMMMd('ar').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat.jm('ar').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} • ${formatTime(dateTime)}';
  }

  static String formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final isToday = now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day;

    if (isToday) {
      return DateFormat.jm('ar').format(dateTime);
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.year == dateTime.year &&
        yesterday.month == dateTime.month &&
        yesterday.day == dateTime.day) {
      return 'أمس';
    }

    final isThisYear = now.year == dateTime.year;
    if (isThisYear) {
      return DateFormat.MMMd('ar').format(dateTime);
    }

    return DateFormat.yMMMd('ar').format(dateTime);
  }

  static String formatNotificationTime(DateTime dateTime) {
    return relativeTime(dateTime);
  }
}