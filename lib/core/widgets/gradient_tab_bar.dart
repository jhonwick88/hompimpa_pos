import 'package:flutter/material.dart';

enum TabBarStyle {
  underline,
  pill,
}

class GradientTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TabController controller;
  final List<String> titles;
  final List<int>? badgeCounts;
  final TabBarStyle style;

  const GradientTabBar({
    super.key,
    required this.controller,
    required this.titles,
    this.badgeCounts,
    this.style = TabBarStyle.underline,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      indicator: style == TabBarStyle.underline
          ? const UnderlineTabIndicator(
              borderSide: BorderSide(width: 3, color: Colors.white),
              insets: EdgeInsets.symmetric(horizontal: 24),
            )
          : BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      tabs: List.generate(
        titles.length,
        (index) => Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(titles[index]),
              if (badgeCounts != null &&
                  index < badgeCounts!.length &&
                  badgeCounts![index] > 0) ...[
                const SizedBox(width: 6),
                _Badge(count: badgeCounts![index]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;

  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
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
