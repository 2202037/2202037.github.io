import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/dashboard_screen.dart';
import '../../features/directory/doctors_screen.dart';
import '../../features/directory/doctor_detail_screen.dart';
import '../../features/directory/clinics_screen.dart';
import '../../features/appointments/appointments_screen.dart';
import '../../features/appointments/book_appointment_screen.dart';
import '../../features/blood_bank/blood_bank_screen.dart';
import '../../features/pharmacy/pharmacy_screen.dart';
import '../../features/pharmacy/cart_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) return null;
      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/home/directory',
            builder: (context, state) => const DoctorsScreen(),
          ),
          GoRoute(
            path: '/home/clinics',
            builder: (context, state) => const ClinicsScreen(),
          ),
          GoRoute(
            path: '/home/appointments',
            builder: (context, state) => const AppointmentsScreen(),
          ),
          GoRoute(
            path: '/home/pharmacy',
            builder: (context, state) => const PharmacyScreen(),
          ),
          GoRoute(
            path: '/home/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/doctor/:id',
        builder: (context, state) {
          final doctorId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return DoctorDetailScreen(doctorId: doctorId);
        },
      ),
      GoRoute(
        path: '/book-appointment/:doctorId',
        builder: (context, state) {
          final doctorId = int.tryParse(state.pathParameters['doctorId'] ?? '0') ?? 0;
          return BookAppointmentScreen(doctorId: doctorId);
        },
      ),
      GoRoute(
        path: '/blood-bank',
        builder: (context, state) => const BloodBankScreen(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
