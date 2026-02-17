import 'package:flutter/material.dart';

enum TabBarStyle {
  underline,
  pill,
}

class GradientStatusTabItem {
  final String title;
  final IconData icon;
  final int count;
  final Color color;

  const GradientStatusTabItem({
    required this.title,
    required this.icon,
    required this.count,
    required this.color,
  });
}

class GradientStatusTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  final List<GradientStatusTabItem> items;
  final TabBarStyle style;
  final bool isScrollable;

  const GradientStatusTabBar({
    super.key,
    required this.items,
    this.style = TabBarStyle.underline,
    this.isScrollable = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: isScrollable,
      indicator: style == TabBarStyle.underline
          ? const UnderlineTabIndicator(
              borderSide: BorderSide(width: 3, color: Colors.white),
              insets: EdgeInsets.symmetric(horizontal: 16),
            )
          : BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      tabs: items.map((item) {
        return Tab(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.count > 0) ...[
                  const SizedBox(width: 6),
                  _StatusBadge(
                    count: item.count,
                    color: item.color,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _StatusBadge({
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
