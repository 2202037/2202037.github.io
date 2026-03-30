import '../core/utils/date_utils.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  static AppointmentStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }
}

class AppointmentModel {
  final int id;
  final int patientId;
  final int doctorId;
  final String patientName;
  final String doctorName;
  final String doctorSpecialty;
  final String? doctorImageUrl;
  final DateTime appointmentDate;
  final String timeSlot;
  final AppointmentStatus status;
  final double fee;
  final String? notes;
  final String? clinicName;
  final String? clinicAddress;
  final DateTime? createdAt;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    required this.doctorSpecialty,
    this.doctorImageUrl,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    required this.fee,
    this.notes,
    this.clinicName,
    this.clinicAddress,
    this.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as int,
      patientId: json['patient_id'] as int,
      doctorId: json['doctor_id'] as int,
      patientName: json['patient_name'] as String? ?? '',
      doctorName: json['doctor_name'] as String? ?? '',
      doctorSpecialty: json['doctor_specialty'] as String? ?? '',
      doctorImageUrl: json['doctor_image_url'] as String?,
      appointmentDate: DateTime.parse(json['appointment_date'] as String),
      timeSlot: json['time_slot'] as String,
      status: AppointmentStatus.fromString(json['status'] as String?),
      fee: (json['fee'] as num).toDouble(),
      notes: json['notes'] as String?,
      clinicName: json['clinic_name'] as String?,
      clinicAddress: json['clinic_address'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'doctor_id': doctorId,
        'patient_name': patientName,
        'doctor_name': doctorName,
        'doctor_specialty': doctorSpecialty,
        if (doctorImageUrl != null) 'doctor_image_url': doctorImageUrl,
        'appointment_date': appointmentDate.toIso8601String(),
        'time_slot': timeSlot,
        'status': status.name,
        'fee': fee,
        if (notes != null) 'notes': notes,
        if (clinicName != null) 'clinic_name': clinicName,
        if (clinicAddress != null) 'clinic_address': clinicAddress,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  String get formattedDate => AppDateUtils.formatDate(appointmentDate);
  String get formattedFee => '₹${fee.toStringAsFixed(0)}';
  String get friendlyDate => AppDateUtils.friendlyDate(appointmentDate);

  bool get isUpcoming =>
      status == AppointmentStatus.pending ||
      status == AppointmentStatus.confirmed;
  bool get isPast => status == AppointmentStatus.completed;
  bool get isCancelled => status == AppointmentStatus.cancelled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppointmentModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Sample data
List<AppointmentModel> get sampleAppointments => [
      AppointmentModel(
        id: 1,
        patientId: 1,
        doctorId: 1,
        patientName: 'John Doe',
        doctorName: 'Dr. Priya Sharma',
        doctorSpecialty: 'Cardiologist',
        appointmentDate: DateTime.now().add(const Duration(days: 2)),
        timeSlot: '10:00 AM',
        status: AppointmentStatus.confirmed,
        fee: 800,
        clinicName: 'Heart Care Clinic',
        clinicAddress: 'MG Road, Bangalore',
      ),
      AppointmentModel(
        id: 2,
        patientId: 1,
        doctorId: 2,
        patientName: 'John Doe',
        doctorName: 'Dr. Rajesh Kumar',
        doctorSpecialty: 'General Physician',
        appointmentDate: DateTime.now().subtract(const Duration(days: 5)),
        timeSlot: '11:30 AM',
        status: AppointmentStatus.completed,
        fee: 500,
        clinicName: 'HealthFirst Clinic',
      ),
    ];
