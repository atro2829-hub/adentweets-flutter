import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DateFormatter {
  DateFormatter._();

  static String formatFullDate(DateTime date) {
    return DateFormat('yyyy/MM/dd HH:mm', 'ar').format(date);
  }

  static String formatDateOnly(DateTime date) {
    return DateFormat('yyyy/MM/dd', 'ar').format(date);
  }

  static String formatTimeOnly(DateTime date) {
    return DateFormat('HH:mm', 'ar').format(date);
  }

  static String formatRelative(DateTime date) {
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    return timeago.format(date, locale: 'ar');
  }

  static String formatDayName(DateTime date) {
    const days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return days[date.weekday % 7];
  }

  static String formatMonthYear(DateTime date) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  static String formatChartDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours ساعة ${minutes > 0 ? 'و $minutes دقيقة' : ''}';
    }
    return '$minutes دقيقة';
  }

  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}م';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}ك';
    }
    return number.toString();
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'مساء الخير';
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء الخير';
  }
}