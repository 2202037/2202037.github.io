class AppConstants {
  AppConstants._();

  static const String appName = 'Ayur Healthcare';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_done';
  static const String themeKey = 'app_theme';

  // Hive boxes
  static const String userBox = 'user_box';
  static const String cacheBox = 'cache_box';

  // Pagination
  static const int pageSize = 20;

  // Blood groups
  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  // Specialties
  static const List<String> specialties = [
    'All',
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Orthopedic',
    'Pediatrician',
    'Neurologist',
    'Gynecologist',
    'Ophthalmologist',
    'ENT Specialist',
    'Dentist',
    'Psychiatrist',
  ];

  // Roles
  static const String rolePatient = 'patient';
  static const String roleDoctor = 'doctor';
  static const String roleClinic = 'clinic';
  static const String rolePharmacy = 'pharmacy';
  static const String roleAdmin = 'admin';

  // Appointment status
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Time slots
  static const List<String> morningSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM',
  ];
  static const List<String> afternoonSlots = [
    '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM',
    '02:00 PM', '02:30 PM',
  ];
  static const List<String> eveningSlots = [
    '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM',
    '06:00 PM', '06:30 PM',
  ];
}
