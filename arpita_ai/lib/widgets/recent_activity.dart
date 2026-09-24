

import 'dart:ui';

import 'package:flutter/material.dart';

class RecentActivity extends StatefulWidget {
  final void Function(RecentActivityItem item)? onItemTap;
  final VoidCallback? onViewAllTap;

  const RecentActivity({
    super.key,
    this.onItemTap,
    this.onViewAllTap,
  });

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  static const List<RecentActivityItem> _activities = [
    RecentActivityItem(
      title: 'Explain Quantum Physics',
      subtitle: 'AI Chat',
      time: '2 minutes ago',
      icon: Icons.chat_bubble_rounded,
      color: Color(0xFFE53935),
    ),
    RecentActivityItem(
      title: 'Generate Anime Artwork',
      subtitle: 'Image AI',
      time: '15 minutes ago',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFFFA000),
    ),
    RecentActivityItem(
      title: 'Flutter Login UI',
      subtitle: 'Code AI',
      time: 'Yesterday',
      icon: Icons.code_rounded,
      color: Color(0xFF1976D2),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(colorScheme),
            const SizedBox(height: 16),
            ...List.generate(
              _activities.length,
              (index) {
                final item = _activities[index];

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == _activities.length - 1 ? 0 : 12,
                  ),
                  child: _ActivityTile(
                    item: item,
                    index: index,
                    onTap: () {
                      widget.onItemTap?.call(item);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        TextButton(
          onPressed: widget.onViewAllTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
          ),
          child: const Text(
            'View all',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatefulWidget {
  final RecentActivityItem item;
  final int index;
  final VoidCallback onTap;

  const _ActivityTile({
    required this.item,
    required this.index,
    required this.onTap,
  });

  @override
  State<_ActivityTile> createState() => _ActivityTileState();
}

class _ActivityTileState extends State<_ActivityTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.055)
                    : Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.9),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.item.color.withValues(
                      alpha: _pressed ? 0.12 : 0.055,
                    ),
                    blurRadius: _pressed ? 18 : 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildActivityIcon(isDark),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildActivityText(theme),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 23,
                    color: theme.colorScheme.onSurface.withValues(
                      alpha: 0.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityIcon(bool isDark) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: widget.item.color.withValues(
          alpha: isDark ? 0.16 : 0.10,
        ),
      ),
      child: Icon(
        widget.item.icon,
        color: widget.item.color,
        size: 23,
      ),
    );
  }

  Widget _buildActivityText(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Flexible(
              child: Text(
                widget.item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: widget.item.color,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                widget.item.time,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  color: theme.colorScheme.onSurface.withValues(
                    alpha: 0.48,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Data model for a single recent activity.
class RecentActivityItem {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  const RecentActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });
}
