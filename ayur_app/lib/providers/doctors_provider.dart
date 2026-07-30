import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../models/doctor_model.dart';
import '../core/constants/api_constants.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class DoctorsState {
  final List<DoctorModel> doctors;
  final List<DoctorModel> filteredDoctors;
  final bool isLoading;
  final String? error;
  final String selectedSpecialty;
  final String searchQuery;

  const DoctorsState({
    this.doctors = const [],
    this.filteredDoctors = const [],
    this.isLoading = false,
    this.error,
    this.selectedSpecialty = 'All',
    this.searchQuery = '',
  });

  DoctorsState copyWith({
    List<DoctorModel>? doctors,
    List<DoctorModel>? filteredDoctors,
    bool? isLoading,
    String? error,
    String? selectedSpecialty,
    String? searchQuery,
    bool clearError = false,
  }) {
    return DoctorsState(
      doctors: doctors ?? this.doctors,
      filteredDoctors: filteredDoctors ?? this.filteredDoctors,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedSpecialty: selectedSpecialty ?? this.selectedSpecialty,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DoctorsNotifier extends StateNotifier<DoctorsState> {
  final ApiService _apiService;

  DoctorsNotifier(this._apiService) : super(const DoctorsState()) {
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.get(ApiConstants.doctors);
      final data = response.data as Map<String, dynamic>;
      final doctorsList = (data['doctors'] as List<dynamic>? ??
              data['data'] as List<dynamic>? ??
              [])
          .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        doctors: doctorsList,
        filteredDoctors: doctorsList,
        isLoading: false,
      );
    } on DioException catch (e) {
      // Use sample data on error (development mode)
      final samples = sampleDoctors;
      state = state.copyWith(
        doctors: samples,
        filteredDoctors: samples,
        isLoading: false,
        error: mapDioError(e).message,
      );
    } catch (e) {
      final samples = sampleDoctors;
      state = state.copyWith(
        doctors: samples,
        filteredDoctors: samples,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void filterBySpecialty(String specialty) {
    state = state.copyWith(selectedSpecialty: specialty);
    _applyFilters();
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = state.doctors;

    if (state.selectedSpecialty != 'All') {
      filtered = filtered
          .where((d) => d.specialty == state.selectedSpecialty)
          .toList();
    }

    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      filtered = filtered
          .where((d) =>
              d.name.toLowerCase().contains(q) ||
              d.specialty.toLowerCase().contains(q) ||
              (d.clinicName?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    state = state.copyWith(filteredDoctors: filtered);
  }

  DoctorModel? getDoctorById(int id) {
    try {
      return state.doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}

final doctorsProvider =
    StateNotifierProvider<DoctorsNotifier, DoctorsState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return DoctorsNotifier(apiService);
});

final doctorByIdProvider = Provider.family<DoctorModel?, int>((ref, id) {
  return ref.watch(doctorsProvider.notifier).getDoctorById(id);
});
