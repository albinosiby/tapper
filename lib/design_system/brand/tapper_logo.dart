import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/assest_path.dart';

/// The Tapper logo. Picks the light or dark version from the theme.
///
/// Minimum sizes: mark 24px tall, wordmark 96px wide. Never recolour,
/// stretch, shadow or gradient it.
class TapperLogo extends StatelessWidget {
  /// Mark, "Tapper" and ടാപ്പർ — the primary logo.
  const TapperLogo.wordmark({super.key, this.height}) : _mark = false;

  /// The leaf-and-drop mark alone.
  const TapperLogo.mark({super.key, this.height}) : _mark = true;

  /// Already in ScreenUtil units (e.g. `36.h`); defaults to `48.h`.
  final double? height;
  final bool _mark;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final asset = switch ((_mark, dark)) {
      (true, _) => AssetPaths.logoMark,
      (false, true) => AssetPaths.logoWordmarkDark,
      (false, false) => AssetPaths.logoWordmark,
    };
    return SvgPicture.asset(
      asset,
      height: height ?? 48.h,
      semanticsLabel: 'Tapper',
    );
  }
}
