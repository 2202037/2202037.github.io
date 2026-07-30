import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/clinics_provider.dart';
import '../../models/clinic_model.dart';

class ClinicsScreen extends ConsumerWidget {
  const ClinicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicsState = ref.watch(clinicsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clinics Nearby'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(clinicsProvider.notifier).fetchClinics(),
        color: AppColors.primary,
        child: clinicsState.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : clinicsState.clinics.isEmpty
                ? const Center(child: Text('No clinics found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: clinicsState.clinics.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ClinicCard(
                          clinic: clinicsState.clinics[index],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  final ClinicModel clinic;

  const _ClinicCard({required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        clinic.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: clinic.isOpen
                            ? AppColors.successLight
                            : AppColors.errorLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        clinic.isOpen ? 'Open' : 'Closed',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: clinic.isOpen
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        clinic.address,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (clinic.rating != null) ...[
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        clinic.formattedRating,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (clinic.reviewCount != null)
                        Text(
                          ' (${clinic.reviewCount})',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      const SizedBox(width: 12),
                    ],
                    if (clinic.distance != null) ...[
                      const Icon(
                        Icons.directions_walk_rounded,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        clinic.formattedDistance,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                if (clinic.specialties != null &&
                    clinic.specialties!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: clinic.specialties!
                        .take(3)
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
