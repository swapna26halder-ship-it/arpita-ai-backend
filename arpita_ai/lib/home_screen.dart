
import 'package:flutter/material.dart';

import 'widgets/home_header.dart';
import 'widgets/feature_grid.dart';
import 'widgets/recent_activity.dart';
import 'widgets/ai_status_card.dart';
import 'widgets/home_botton_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  void _onFeatureTap(String feature) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature selected'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onRecentActivityTap(
    RecentActivityItem item,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(item.title),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onNavigationChanged(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  void _onAskAi() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI Chat will open here 🤖'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onNotificationTap() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onViewAllActivity() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All activity'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onAiStatusTap() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Arpita AI is online 🚀'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,

      backgroundColor: isDark
          ? const Color(0xFF0D0D0D)
          : const Color(0xFFFFFBF7),

      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                120,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    // ─────────────────────────
                    // HEADER
                    // ─────────────────────────

                    HomeHeader(
                      onNotificationTap:
                          _onNotificationTap,
                    ),

                    const SizedBox(height: 28),

                    // ─────────────────────────
                    // FEATURE GRID
                    // ─────────────────────────

                    FeatureGrid(
                      onFeatureTap:
                          _onFeatureTap,
                    ),

                    const SizedBox(height: 28),

                    // ─────────────────────────
                    // AI STATUS
                    // ─────────────────────────

                    AiStatusCard(
                      onTap: _onAiStatusTap,
                    ),

                    const SizedBox(height: 32),

                    // ─────────────────────────
                    // RECENT ACTIVITY
                    // ─────────────────────────

                    RecentActivity(
                      onItemTap:
                          _onRecentActivityTap,
                      onViewAllTap:
                          _onViewAllActivity,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ─────────────────────────────────────
      // CUSTOM BOTTOM NAVIGATION
      // ─────────────────────────────────────

      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentNavIndex,
        onItemSelected:
            _onNavigationChanged,
        onAskAi: _onAskAi,
      ),
    );
  }}