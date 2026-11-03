import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../design_system/design_system.dart';

/// Employees: one WorkerCard per tapper. Sample data until the employees
/// module's BLoC and repository are added.
class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void todo(String what) => AppDialogs.showSnackBar(context, what);

    return Scaffold(
      appBar: AppBar(title: const Text('Employees')),
      floatingActionButton: TpFab(
        tooltip: 'Add worker',
        onPressed: () => todo('Add worker'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(Spacing.s4, 0, Spacing.s4, 96.h),
        children: [
          WorkerCard(
            name: 'Raju',
            rates: 'Plot A ₹1.75 · Plot B ₹1.80 per tree',
            days: 21,
            earned: 16240,
            paid: 16290,
            onAddPayment: () => todo('Add payment'),
            onHistory: () => todo('History'),
          ),
          SizedBox(height: Spacing.s4),
          WorkerCard(
            name: 'Suresh',
            rates: 'Plot B ₹1.80 per tree',
            days: 18,
            earned: 14580,
            paid: 14105,
            onAddPayment: () => todo('Add payment'),
            onHistory: () => todo('History'),
          ),
        ],
      ),
    );
  }
}
