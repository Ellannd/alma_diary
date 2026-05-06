import 'package:flutter/material.dart';

class AlmaNavbarItem {
  final IconData icon;
  final String label;

  const AlmaNavbarItem({
    required this.icon,
    required this.label,
  });
}

class AlmaNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int notificationCount;

  const AlmaNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = [
      const AlmaNavbarItem(icon: Icons.home_outlined, label: 'Home'),
      const AlmaNavbarItem(icon: Icons.search, label: 'Buscar'),
      const AlmaNavbarItem(icon: Icons.add_circle_outline, label: 'Nuevo'),
      const AlmaNavbarItem(icon: Icons.notifications_outlined, label: 'Notifs'),
      const AlmaNavbarItem(icon: Icons.person_outline, label: 'Perfil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: _NavItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                  showBadge: index == 3 && notificationCount > 0,
                  badgeCount: notificationCount,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AlmaNavbarItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showBadge;
  final int badgeCount;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.showBadge,
    required this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final activeColor = theme.colorScheme.primary;
    final inactiveColor =
        theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6) ??
            Colors.grey;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                if (showBadge)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}