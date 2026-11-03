import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 24px line icons, 1.8 stroke, rounded caps and joins (TabBar style).
/// Add new icons in the same style.
enum TapperIcon {
  home(
    '<rect x="3" y="5" width="18" height="16" rx="3"/>'
    '<path d="M3 10h18M8 3v4M16 3v4"/>',
  ),
  accounts('<path d="M4 19V9M10 19V5M16 19v-7M21 19H3"/>'),
  employees(
    '<circle cx="9" cy="8" r="3.5"/>'
    '<path d="M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6M16 4.5a3.5 3.5 0 0 1 0 7M18 14c2 .7 3 2.8 3 6"/>',
  ),
  settings(
    '<circle cx="12" cy="12" r="3"/>'
    '<path d="M12 2v3M12 19v3M2 12h3M19 12h3M4.9 4.9l2.1 2.1M17 17l2.1 2.1M4.9 19.1 7 17M17 7l2.1-2.1"/>',
  );

  const TapperIcon(this.body);

  final String body;

  String get svg =>
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
      'stroke="#000" stroke-width="1.8" stroke-linecap="round" '
      'stroke-linejoin="round">$body</svg>';
}

class TpIcon extends StatelessWidget {
  const TpIcon(this.icon, {super.key, this.color, this.size});

  final TapperIcon icon;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? IconTheme.of(context).color ?? Colors.black;
    final dimension = size ?? 24.r;
    return SvgPicture.string(
      icon.svg,
      width: dimension,
      height: dimension,
      colorFilter: ColorFilter.mode(resolved, BlendMode.srcIn),
    );
  }
}
