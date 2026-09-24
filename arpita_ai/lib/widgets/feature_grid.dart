import 'dart:ui';

import 'package:flutter/material.dart';

class FeatureGrid extends StatelessWidget {
  final void Function(String feature)? onFeatureTap;

  const FeatureGrid({
    super.key,
    this.onFeatureTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final int columns;

        if (width >= 900) {
          columns = 4;
        } else if (width >= 600) {
          columns = 3;
        } else {
          columns = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _features.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: width < 600 ? 0.92 : 1.05,
          ),
          itemBuilder: (context, index) {
            final feature = _features[index];

            return _FeatureCard(
              feature: feature,
              index: index,
              onTap: () {
                onFeatureTap?.call(feature.title);
              },
            );
          },
        );
      },
    );
  }

  static const List<_FeatureData> _features = [
    _FeatureData(
      title: 'AI Chat',
      subtitle: 'Talk with Arpita AI',
      icon: Icons.chat_rounded,
      color: Color(0xFFE53935),
      tag: 'CHAT',
    ),
    _FeatureData(
      title: 'Image AI',
      subtitle: 'Create stunning images',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFFFA000),
      tag: 'CREATE',
    ),
    _FeatureData(
      title: 'Code AI',
      subtitle: 'Build & debug code',
      icon: Icons.code_rounded,
      color: Color(0xFF1976D2),
      tag: 'CODE',
    ),
    _FeatureData(
      title: 'Web Search',
      subtitle: 'Find information online',
      icon: Icons.language_rounded,
      color: Color(0xFF00897B),
      tag: 'SEARCH',
    ),
    _FeatureData(
      title: 'Camera AI',
      subtitle: 'Understand your camera',
      icon: Icons.camera_alt_rounded,
      color: Color(0xFF7B1FA2),
      tag: 'VISION',
    ),
    _FeatureData(
      title: 'Voice AI',
      subtitle: 'Talk naturally with AI',
      icon: Icons.mic_rounded,
      color: Color(0xFF00838F),
      tag: 'VOICE',
    ),
  ];
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData feature;
  final int index;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.feature,
    required this.index,
    required this.onTap,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;

    setState(() {
      _pressed = value;
    });

    if (value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
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
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.065)
                    : Colors.white.withValues(alpha: 0.72),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.09)
                      : Colors.white.withValues(alpha: 0.9),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.feature.color.withValues(
                      alpha: _pressed ? 0.20 : 0.10,
                    ),
                    blurRadius: _pressed ? 22 : 15,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIcon(isDark),
                      _buildTag(),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    widget.feature.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.feature.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.58,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Open',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: widget.feature.color,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: widget.feature.color,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: widget.feature.color.withValues(
          alpha: isDark ? 0.17 : 0.11,
        ),
      ),
      child: Icon(
        widget.feature.icon,
        color: widget.feature.color,
        size: 27,
      ),
    );
  }

  Widget _buildTag() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: widget.feature.color.withValues(alpha: 0.09),
      ),
      child: Text(
        widget.feature.tag,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
          color: widget.feature.color,
        ),
      ),
    );
  }
}

class _FeatureData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String tag;

  const _FeatureData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tag,
  });
}
