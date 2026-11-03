import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../icons/tapper_icons.dart';
import '../tokens/spacing.dart';
import '../tokens/tapper_colors.dart';
import '../tokens/tapper_typography.dart';

class TpTab {
  const TpTab({required this.icon, required this.label});

  final TapperIcon icon;
  final String label;
}

/// Scaffold for the `StatefulShellRoute`: the page plus the Tapper TabBar.
class TpTabShell extends StatelessWidget {
  const TpTabShell({
    super.key,
    required this.navigationShell,
    required this.tabs,
  });

  final StatefulNavigationShell navigationShell;
  final List<TpTab> tabs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: TpTabBar(
        tabs: tabs,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

/// Bottom navigation: `tabbar-height`, labels always visible, active tab in
/// `leaf` with a `leaf-soft` pill behind the icon.
class TpTabBar extends StatelessWidget {
  const TpTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<TpTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        boxShadow: c.sheetShadow,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: TapperSize.tabBarHeight,
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: _TabItem(
                    tab: tabs[i],
                    active: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final TpTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.tp;
    final color = active ? c.leaf : c.inkMuted;
    return Semantics(
      selected: active,
      button: true,
      label: tab.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.s4,
                vertical: 2.h,
              ),
              decoration: BoxDecoration(
                color: active ? c.leafSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(TapperRadius.pill),
              ),
              child: TpIcon(tab.icon, color: color),
            ),
            SizedBox(height: 2.h),
            Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TapperText.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
