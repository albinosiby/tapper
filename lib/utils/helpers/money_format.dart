import 'package:intl/intl.dart';

/// Money and date formatting rules from the Tapper content guide.
class Money {
  Money._();

  static final NumberFormat _whole = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  static final NumberFormat _paise = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// `₹1,24,500` — Indian digit grouping, paise only when there are any.
  static String format(num amount) {
    final value = amount.abs();
    return (value % 1 == 0 ? _whole : _paise).format(value);
  }

  /// `+ ₹7,770` for income.
  static String income(num amount) => '+ ${format(amount)}';

  /// `− ₹4,200` for expense (true minus sign, U+2212).
  static String expense(num amount) => '− ${format(amount)}';
}

class TapperDates {
  TapperDates._();

  static final DateFormat _list = DateFormat('d MMM');
  static final DateFormat _title = DateFormat('EEE, d MMM');
  static final DateFormat _month = DateFormat('MMMM yyyy');

  /// `27 Oct` in lists.
  static String list(DateTime d) => _list.format(d);

  /// `Mon, 27 Oct` in titles.
  static String title(DateTime d) => _title.format(d);

  /// `October 2026` for the calendar header.
  static String month(DateTime d) => _month.format(d);

  /// `2026–27` for a season starting in [startYear].
  static String season(int startYear) => '$startYear–${(startYear + 1) % 100}';
}
