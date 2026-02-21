import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:serapeum_app/core/presentation/widgets/particle_background.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    String subtitle = '';
    switch (navigationShell.currentIndex) {
      case 0:
        subtitle = 'Library';
        break;
      case 1:
        subtitle = 'Discover';
        break;
      case 2:
        subtitle = 'Control Center';
        break;
    }

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
                'SERAPEUM',
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
                  color: const Color(0xFF930DF2),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent, // Let gradient shine through
          elevation: 0,
          surfaceTintColor: Colors.transparent,
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
                  indicatorColor: const Color(
                    0xFF930DF2,
                  ).withValues(alpha: 0.2),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.library_books_outlined),
                      selectedIcon: Icon(
                        Icons.library_books,
                        color: Color(0xFF930DF2),
                      ),
                      label: 'Library',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(
                        Icons.explore,
                        color: Color(0xFF930DF2),
                      ),
                      label: 'Discover',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(
                        Icons.settings,
                        color: Color(0xFF930DF2),
                      ),
                      label: 'Control Center',
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
