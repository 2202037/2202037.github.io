import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../models/blood_bank_model.dart';
import '../core/constants/api_constants.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class BloodBankState {
  final List<BloodInventoryItem> inventory;
  final bool isLoading;
  final String? error;
  final bool isRequesting;

  const BloodBankState({
    this.inventory = const [],
    this.isLoading = false,
    this.error,
    this.isRequesting = false,
  });

  BloodBankState copyWith({
    List<BloodInventoryItem>? inventory,
    bool? isLoading,
    String? error,
    bool? isRequesting,
    bool clearError = false,
  }) {
    return BloodBankState(
      inventory: inventory ?? this.inventory,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isRequesting: isRequesting ?? this.isRequesting,
    );
  }
}

class BloodBankNotifier extends StateNotifier<BloodBankState> {
  final ApiService _apiService;

  BloodBankNotifier(this._apiService) : super(const BloodBankState()) {
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.get(ApiConstants.bloodInventory);
      final data = response.data as Map<String, dynamic>;
      final list = (data['inventory'] as List<dynamic>? ??
              data['data'] as List<dynamic>? ??
              [])
          .map((e) {
        final m = e as Map<String, dynamic>;
        return BloodInventoryItem(
          bloodGroup: m['blood_group'] as String,
          units: m['units_available'] as int,
        );
      }).toList();
      state = state.copyWith(inventory: list, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        inventory: sampleInventory,
        isLoading: false,
      );
    }
  }

  Future<bool> requestBlood({
    required String bloodGroup,
    required String patientName,
    required String hospital,
    required String phone,
    int units = 1,
  }) async {
    state = state.copyWith(isRequesting: true);
    try {
      await _apiService.post(
        ApiConstants.requestBlood,
        data: {
          'blood_group': bloodGroup,
          'patient_name': patientName,
          'hospital': hospital,
          'phone': phone,
          'units': units,
        },
      );
      state = state.copyWith(isRequesting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isRequesting: false);
      return false;
    }
  }
}

final bloodBankProvider =
    StateNotifierProvider<BloodBankNotifier, BloodBankState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return BloodBankNotifier(apiService);
});
