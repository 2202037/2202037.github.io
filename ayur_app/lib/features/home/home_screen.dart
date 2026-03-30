import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<_NavItem> _items = const [
    _NavItem(icon: Icons.home_rounded, activeIcon: Icons.home_rounded, label: 'Home', path: '/home'),
    _NavItem(icon: Icons.search_rounded, activeIcon: Icons.search_rounded, label: 'Directory', path: '/home/directory'),
    _NavItem(icon: Icons.calendar_month_rounded, activeIcon: Icons.calendar_month_rounded, label: 'Appointments', path: '/home/appointments'),
    _NavItem(icon: Icons.local_pharmacy_outlined, activeIcon: Icons.local_pharmacy_rounded, label: 'Pharmacy', path: '/home/pharmacy'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile', path: '/home/profile'),
  ];

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
    context.go(_items[index].path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
          ),
          items: _items
              .asMap()
              .entries
              .map(
                (entry) => BottomNavigationBarItem(
                  icon: Icon(
                    entry.value.icon,
                    size: 24,
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      entry.value.activeIcon,
                      size: 24,
                      color: AppColors.primary,
                    ),
                  ),
                  label: entry.value.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}
