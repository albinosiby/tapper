import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/spacing.dart';
import '../tokens/tapper_colors.dart';
import '../tokens/tapper_typography.dart';

/// Opens a Tapper bottom sheet: `radius-lg` top corners, `shadow-sheet`,
/// grab handle and a `title`-style heading, on the `scrim`.
Future<T?> showTpSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    // Above the tab bar, so the whole screen dims behind the sheet.
    useRootNavigator: true,
    useSafeArea: true,
    builder: (sheetContext) =>
        TpSheet(title: title, child: builder(sheetContext)),
  );
}

class TpSheet extends StatelessWidget {
  const TpSheet({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          boxShadow: c.sheetShadow,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(TapperRadius.lg),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Spacing.s4,
            Spacing.s3,
            Spacing.s4,
            Spacing.s6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: c.lineStrong,
                    borderRadius: BorderRadius.circular(TapperRadius.pill),
                  ),
                ),
              ),
              SizedBox(height: Spacing.s3),
              Text(title, style: TapperText.title.copyWith(color: c.ink)),
              SizedBox(height: Spacing.s4),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Short confirmation / info messages.
class AppDialogs {
  AppDialogs._();

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
