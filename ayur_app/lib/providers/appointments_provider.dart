import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../models/appointment_model.dart';
import '../core/constants/api_constants.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class AppointmentsState {
  final List<AppointmentModel> appointments;
  final bool isLoading;
  final String? error;
  final bool isBooking;

  const AppointmentsState({
    this.appointments = const [],
    this.isLoading = false,
    this.error,
    this.isBooking = false,
  });

  List<AppointmentModel> get upcoming =>
      appointments.where((a) => a.isUpcoming).toList();
  List<AppointmentModel> get past =>
      appointments.where((a) => a.isPast).toList();
  List<AppointmentModel> get cancelled =>
      appointments.where((a) => a.isCancelled).toList();

  AppointmentsState copyWith({
    List<AppointmentModel>? appointments,
    bool? isLoading,
    String? error,
    bool? isBooking,
    bool clearError = false,
  }) {
    return AppointmentsState(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isBooking: isBooking ?? this.isBooking,
    );
  }
}

class AppointmentsNotifier extends StateNotifier<AppointmentsState> {
  final ApiService _apiService;

  AppointmentsNotifier(this._apiService) : super(const AppointmentsState()) {
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiService.get(ApiConstants.appointments);
      final data = response.data as Map<String, dynamic>;
      final list = (data['appointments'] as List<dynamic>? ??
              data['data'] as List<dynamic>? ??
              [])
          .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(appointments: list, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        appointments: sampleAppointments,
        error: mapDioError(e).message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        appointments: sampleAppointments,
      );
    }
  }

  Future<bool> bookAppointment({
    required int doctorId,
    required DateTime date,
    required String timeSlot,
    String? notes,
  }) async {
    state = state.copyWith(isBooking: true, clearError: true);
    try {
      final response = await _apiService.post(
        ApiConstants.bookAppointment,
        data: {
          'doctor_id': doctorId,
          'appointment_date': date.toIso8601String().split('T').first,
          'time_slot': timeSlot,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final apptData = data['appointment'] as Map<String, dynamic>? ?? data;
      final newAppointment = AppointmentModel.fromJson(apptData);
      state = state.copyWith(
        appointments: [newAppointment, ...state.appointments],
        isBooking: false,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isBooking: false,
        error: mapDioError(e).message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(isBooking: false, error: e.toString());
      return false;
    }
  }

  Future<bool> cancelAppointment(int appointmentId) async {
    try {
      await _apiService.post(
        ApiConstants.cancelAppointment.replaceAll('{id}', '$appointmentId'),
      );
      final updated = state.appointments.map((a) {
        if (a.id == appointmentId) {
          return AppointmentModel(
            id: a.id,
            patientId: a.patientId,
            doctorId: a.doctorId,
            patientName: a.patientName,
            doctorName: a.doctorName,
            doctorSpecialty: a.doctorSpecialty,
            appointmentDate: a.appointmentDate,
            timeSlot: a.timeSlot,
            status: AppointmentStatus.cancelled,
            fee: a.fee,
          );
        }
        return a;
      }).toList();
      state = state.copyWith(appointments: updated);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final appointmentsProvider =
    StateNotifierProvider<AppointmentsNotifier, AppointmentsState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AppointmentsNotifier(apiService);
});
