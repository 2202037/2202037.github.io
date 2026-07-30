import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointments_provider.dart';
import '../../providers/doctors_provider.dart';
import '../../shared/widgets/doctor_card.dart';
import '../../shared/widgets/appointment_card.dart';
import '../../shared/widgets/section_header.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final appointmentsState = ref.watch(appointmentsProvider);
    final doctorsState = ref.watch(doctorsProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(appointmentsProvider.notifier).fetchAppointments(),
              ref.read(doctorsProvider.notifier).fetchDoctors(),
            ]);
          },
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: _buildTopBar(context, user?.name ?? 'User'),
              ),

              // Health Tip Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _buildHealthTipCard(),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _buildQuickActions(context),
                ),
              ),

              // Upcoming Appointments
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: SectionHeader(
                    title: 'Upcoming Appointments',
                    onViewAll: () => context.go('/home/appointments'),
                  ),
                ),
              ),

              if (appointmentsState.isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              else if (appointmentsState.upcoming.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: _buildEmptyAppointments(context),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final appts = appointmentsState.upcoming
                          .take(3)
                          .toList();
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: AppointmentCard(
                          appointment: appts[index],
                          onTap: () {},
                        ),
                      );
                    },
                    childCount: appointmentsState.upcoming.take(3).length,
                  ),
                ),

              // Find Specialists
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: SectionHeader(
                    title: 'Find Specialists',
                    onViewAll: () => context.go('/home/directory'),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 210,
                  child: doctorsState.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount:
                              doctorsState.doctors.take(8).length,
                          itemBuilder: (context, index) {
                            final doctor =
                                doctorsState.doctors.take(8).toList()[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < 7 ? 12 : 0,
                              ),
                              child: DoctorCard(
                                doctor: doctor,
                                isHorizontal: true,
                                onTap: () =>
                                    context.push('/doctor/${doctor.id}'),
                              ),
                            );
                          },
                        ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String userName) {
    final firstName = userName.split(' ').first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  firstName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '💡 Health Tip',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Stay hydrated! Drink 8 glasses of water daily for better health.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Learn More',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(
            Icons.water_drop_rounded,
            color: Colors.white,
            size: 64,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        label: 'Find\nDoctor',
        icon: Icons.medical_services_rounded,
        color: AppColors.doctorActionColor,
        onTap: () => context.go('/home/directory'),
      ),
      _QuickAction(
        label: 'Blood\nBank',
        icon: Icons.water_drop_rounded,
        color: AppColors.bloodActionColor,
        onTap: () => context.push('/blood-bank'),
      ),
      _QuickAction(
        label: 'Clinics\nNearby',
        icon: Icons.local_hospital_rounded,
        color: AppColors.clinicActionColor,
        onTap: () => context.go('/home/clinics'),
      ),
      _QuickAction(
        label: 'Pharmacy',
        icon: Icons.local_pharmacy_rounded,
        color: AppColors.pharmacyActionColor,
        onTap: () => context.go('/home/pharmacy'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) => _QuickActionItem(action: action)).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyAppointments(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 40,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 8),
          const Text(
            'No upcoming appointments',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/home/directory'),
            child: const Text(
              'Book an appointment',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionItem extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionItem({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(action.icon, color: action.color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
