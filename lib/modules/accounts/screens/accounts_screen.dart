import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../design_system/design_system.dart';
import '../../../utils/helpers/money_format.dart';

/// Accounts: season summary and income / expense history. Sample data until
/// the accounts module's BLoC and repository are added.
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      floatingActionButton: TpFab(
        tooltip: 'Add entry',
        onPressed: () => AppDialogs.showSnackBar(context, 'Add entry'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(Spacing.s4, 0, Spacing.s4, 96.h),
        children: [
          SeasonSummary(
            seasonLabel: 'Season ${TapperDates.season(2026)} · since 1 Jun',
            income: 286300,
            expenses: 161800,
            pending: 3450,
          ),
          SizedBox(height: Spacing.s6),
          const MoneyList(
            children: [
              MoneyRow(
                title: 'Sheet sold · 42 kg × ₹185',
                meta: '27 Oct · Mathew Traders',
                amount: 7770,
                direction: MoneyDirection.income,
                badge: TpBadge.due('₹270 due'),
              ),
              MoneyRow(
                title: 'Rain guarding',
                meta: '25 Oct · Plot A · plastic + glue',
                amount: 4200,
                direction: MoneyDirection.expense,
              ),
              MoneyRow(
                title: 'Raw latex sold · 60 ltr × ₹120',
                meta: '22 Oct · DRC 35%',
                amount: 7200,
                direction: MoneyDirection.income,
              ),
              MoneyRow(
                title: 'Wage paid · Raju',
                meta: '20 Oct · Cash',
                amount: 800,
                direction: MoneyDirection.expense,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
