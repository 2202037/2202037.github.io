import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/doctor_model.dart';
import '../../providers/doctors_provider.dart';
import '../../shared/widgets/custom_button.dart';

class DoctorDetailScreen extends ConsumerWidget {
  final int doctorId;

  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = ref.watch(doctorByIdProvider(doctorId));

    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Doctor Detail')),
        body: const Center(child: Text('Doctor not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, doctor),
          SliverToBoxAdapter(
            child: _buildContent(context, doctor),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, doctor),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, DoctorModel doctor) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16),
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.healthGradient),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Doctor Avatar
                Hero(
                  tag: 'doctor-${doctor.id}',
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      child: Text(
                        doctor.initials,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatChip(
                        '⭐ ${doctor.formattedRating}', 'Rating'),
                    const SizedBox(width: 16),
                    if (doctor.experienceYears != null)
                      _buildStatChip(
                          '${doctor.experienceYears} yrs', 'Experience'),
                    const SizedBox(width: 16),
                    _buildStatChip(doctor.formattedFee, 'Fee'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: Colors.white.withOpacity(0.75),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, DoctorModel doctor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Availability badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: doctor.isAvailable
                      ? AppColors.successLight
                      : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: doctor.isAvailable
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      doctor.isAvailable
                          ? 'Available Today'
                          : 'Not Available',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: doctor.isAvailable
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              if (doctor.distance != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        doctor.formattedDistance,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),

          // Clinic Info
          if (doctor.clinicName != null)
            _buildInfoCard(
              icon: Icons.local_hospital_rounded,
              title: doctor.clinicName!,
              subtitle: doctor.clinicAddress,
              color: AppColors.clinicActionColor,
            ),

          if (doctor.phone != null) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.phone_rounded,
              title: doctor.phone!,
              color: AppColors.success,
            ),
          ],

          const SizedBox(height: 20),

          // Bio
          if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
            const Text(
              'About',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              doctor.bio!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _buildStatCard(
                label: 'Experience',
                value: doctor.formattedExperience,
                icon: Icons.workspace_premium_rounded,
                color: AppColors.info,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: 'Patients',
                value: '${(doctor.reviewCount ?? 0) * 5}+',
                icon: Icons.people_rounded,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                label: 'Reviews',
                value: '${doctor.reviewCount ?? 0}',
                icon: Icons.star_rounded,
                color: AppColors.warning,
              ),
            ],
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, DoctorModel doctor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: doctor.isAvailable
                  ? () => context.push('/book-appointment/${doctor.id}')
                  : null,
              child: Text(
                doctor.isAvailable ? 'Book Appointment' : 'Not Available',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
