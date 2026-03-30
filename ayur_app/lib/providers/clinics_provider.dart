import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../models/clinic_model.dart';
import '../core/constants/api_constants.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class ClinicsState {
  final List<ClinicModel> clinics;
  final bool isLoading;
  final String? error;

  const ClinicsState({
    this.clinics = const [],
    this.isLoading = false,
    this.error,
  });

  ClinicsState copyWith({
    List<ClinicModel>? clinics,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ClinicsState(
      clinics: clinics ?? this.clinics,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ClinicsNotifier extends StateNotifier<ClinicsState> {
  final ApiService _apiService;

  ClinicsNotifier(this._apiService) : super(const ClinicsState()) {
    fetchClinics();
  }

  Future<void> fetchClinics() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.get(ApiConstants.clinics);
      final data = response.data as Map<String, dynamic>;
      final list = (data['clinics'] as List<dynamic>? ??
              data['data'] as List<dynamic>? ??
              [])
          .map((e) => ClinicModel.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(clinics: list, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        clinics: _sampleClinics,
        error: mapDioError(e).message,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, clinics: _sampleClinics);
    }
  }

  static final List<ClinicModel> _sampleClinics = const [
    ClinicModel(
      id: 1,
      name: 'Apollo Clinic',
      address: 'MG Road, Bangalore - 560001',
      phone: '+91 80 4040 1066',
      rating: 4.5,
      reviewCount: 320,
      distance: 1.2,
      isOpen: true,
      specialties: ['Cardiology', 'General Medicine', 'Orthopedic'],
    ),
    ClinicModel(
      id: 2,
      name: 'Manipal Health Clinic',
      address: 'HAL Airport Road, Bangalore',
      phone: '+91 80 2222 4477',
      rating: 4.7,
      reviewCount: 450,
      distance: 2.5,
      isOpen: true,
      specialties: ['Neurology', 'Pediatrics', 'Dermatology'],
    ),
    ClinicModel(
      id: 3,
      name: 'Columbia Asia Hospital',
      address: 'Hebbal, Bangalore - 560024',
      phone: '+91 80 7179 7777',
      rating: 4.6,
      reviewCount: 280,
      distance: 4.1,
      isOpen: false,
      specialties: ['Oncology', 'Cardiology', 'ENT'],
    ),
  ];
}

final clinicsProvider =
    StateNotifierProvider<ClinicsNotifier, ClinicsState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ClinicsNotifier(apiService);
});
