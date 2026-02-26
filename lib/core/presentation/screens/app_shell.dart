import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import 'package:serapeum_app/core/presentation/widgets/particle_background.dart';

import 'package:serapeum_app/features/discovery/presentation/providers/discovery_provider.dart';
import 'package:serapeum_app/features/discovery/presentation/screens/discovery_history_screen.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final String subtitle = switch (navigationShell.currentIndex) {
      0 => l10n.myLibraryTitle,
      1 => l10n.discoverTitle,
      2 => l10n.controlCenterTitle,
      _ => '',
    };

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF06061A), // Dark navy base
            Color(0xFF0A0414), // Deep space transition
            Color(0xFF2B0B55), // Vibrant deep purple accent in the corner
          ],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let the gradient shine through
        appBar: AppBar(
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.appName,
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 2.0,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  color: AppColors.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent, // Let gradient shine through
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          actions: [
            if (navigationShell.currentIndex == 1) ...[
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  ref.read(discoveryProvider.notifier).startNewConversation();
                },
                tooltip: l10n.newConversation,
              ),
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: () async {
                  final query = await showModalBottomSheet<String>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    useRootNavigator: true,
                    builder: (context) => const DiscoveryHistoryScreen(),
                  );

                  if (query != null && context.mounted) {
                    ref.read(discoveryProvider.notifier).executeSearch(query);
                  }
                },
                tooltip: l10n.discoveryHistoryTitle,
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: ParticleBackground()),
            navigationShell,
          ],
        ),
        extendBody: true,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 56.0,
              vertical: 0.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                borderRadius: BorderRadius.circular(32),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: NavigationBar(
                  height: 60,
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (index) {
                    navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    );
                  },
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                  indicatorColor: Colors.transparent, // Removed overlay
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.library_books_outlined),
                      selectedIcon: const Icon(
                        Icons.library_books,
                        color: AppColors.accent,
                      ),
                      label: l10n.myLibraryTitle,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.auto_awesome_outlined),
                      selectedIcon: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.accent,
                      ),
                      label: l10n.discoverTitle,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.settings_outlined),
                      selectedIcon: const Icon(
                        Icons.settings,
                        color: AppColors.accent,
                      ),
                      label: l10n.controlCenterTitle,
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
