import 'package:flutter_test/flutter_test.dart';
import 'package:tapper/utils/helpers/money_format.dart';

void main() {
  test('Indian grouping with signs', () {
    expect(Money.format(124500), '₹1,24,500');
    expect(Money.income(7770), '+ ₹7,770');
    expect(Money.expense(4200), '− ₹4,200');
    expect(Money.format(787.5), '₹787.50');
  });

  test('season label', () {
    expect(TapperDates.season(2026), '2026–27');
  });
}
