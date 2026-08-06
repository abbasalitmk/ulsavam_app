class ApiEndpoints {
  // Change base URL as needed (http://10.0.2.2:8000/api for Android Emulator, http://localhost:8000/api for iOS/Web)
  static const String baseUrl = 'http://10.0.2.2:8000/api/';

  // Auth
  static const String requestOtp = 'auth/otp/request/';
  static const String verifyOtp = 'auth/otp/verify/';
  static const String refreshToken = 'auth/token/refresh/';
  static const String logout = 'auth/logout/';
  static const String userMe = 'auth/me/';

  // Districts
  static const String districts = 'districts/';

  // Events
  static const String events = 'events/';
  static const String happeningNow = 'events/happening-now/';
  static const String calendar = 'events/calendar/';
  static String eventDetail(int id) => 'events/$id/';
  static String eventGoing(int id) => 'events/$id/going/';
  static String eventConfirm(int id) => 'events/$id/confirm/';
  static String eventAttendees(int id) => 'events/$id/attendees/';

  // Notifications
  static const String notifications = 'notifications/';
  static String notificationRead(int id) => 'notifications/$id/read/';
}
