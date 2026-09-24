

import 'dart:ui';

import 'package:flutter/material.dart';

class HomeBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onItemSelected;
  final VoidCallback? onAskAi;

  const HomeBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onItemSelected,
    this.onAskAi,
  });

  @override
  State<HomeBottomNav> createState() => _HomeBottomNavState();
}

class _HomeBottomNavState extends State<HomeBottomNav> {
  static const Color _primaryRed = Color(0xFFB71C1C);
  static const Color _gold = Color(0xFFFFD54F);

  final List<_NavItem> _items = const [
    _NavItem(
      icon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.chat_bubble_rounded,
      label: 'Chats',
    ),
    _NavItem(
      icon: Icons.history_rounded,
      label: 'History',
    ),
    _NavItem(
      icon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 92,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 12,
            right: 12,
            bottom: 8,
            child: _buildNavigationBar(
              context,
              theme,
              isDark,
            ),
          ),
          Positioned(
            top: 0,
            child: _buildAskAiButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF171717).withValues(alpha: 0.88)
                : Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.85),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.25 : 0.08,
                ),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildNavItem(
                  index: 0,
                  item: _items[0],
                  theme: theme,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  index: 1,
                  item: _items[1],
                  theme: theme,
                ),
              ),
              const SizedBox(width: 72),
              Expanded(
                child: _buildNavItem(
                  index: 2,
                  item: _items[2],
                  theme: theme,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  index: 3,
                  item: _items[3],
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required _NavItem item,
    required ThemeData theme,
  }) {
    final selected = widget.currentIndex == index;
    final inactiveColor = theme.colorScheme.onSurface.withValues(
      alpha: 0.48,
    );

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: () {
          widget.onItemSelected?.call(index);
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(
            horizontal: 3,
            vertical: 8,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: selected
                ? _primaryRed.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  item.icon,
                  size: 23,
                  color: selected ? _primaryRed : inactiveColor,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: selected ? _primaryRed : inactiveColor,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAskAiButton(BuildContext context) {
    return GestureDetector(
      onTap: widget.onAskAi,
      child: Hero(
        tag: 'ask-ai-button',
        child: Container(
          width: 68,
          height: 68,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _gold,
                _primaryRed,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryRed.withValues(alpha: 0.30),
                blurRadius: 20,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryRed,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.onAskAi,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                    SizedBox(height: 1),
                    Text(
                      'AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}
