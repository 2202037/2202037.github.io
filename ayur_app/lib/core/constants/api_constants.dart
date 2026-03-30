class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://10.0.2.2/ayur/backend/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  static const String updateProfile = '/auth/profile/update';

  // Doctors
  static const String doctors = '/doctors';
  static const String doctorDetail = '/doctors/{id}';
  static const String doctorsBySpecialty = '/doctors/specialty/{specialty}';
  static const String searchDoctors = '/doctors/search';

  // Clinics
  static const String clinics = '/clinics';
  static const String clinicDetail = '/clinics/{id}';
  static const String nearbyClinics = '/clinics/nearby';

  // Appointments
  static const String appointments = '/appointments';
  static const String appointmentDetail = '/appointments/{id}';
  static const String bookAppointment = '/appointments/book';
  static const String cancelAppointment = '/appointments/{id}/cancel';
  static const String doctorSlots = '/appointments/slots/{doctorId}';

  // Blood Bank
  static const String bloodBank = '/blood-bank';
  static const String bloodInventory = '/blood-bank/inventory';
  static const String requestBlood = '/blood-bank/request';

  // Pharmacy
  static const String pharmacyProducts = '/pharmacy/products';
  static const String pharmacyCategories = '/pharmacy/categories';
  static const String productDetail = '/pharmacy/products/{id}';
  static const String placeOrder = '/pharmacy/orders';
  static const String myOrders = '/pharmacy/orders/my';

  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/{id}/read';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
