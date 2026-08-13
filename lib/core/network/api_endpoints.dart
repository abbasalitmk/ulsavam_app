class ApiEndpoints {
  // Override via --dart-define=API_BASE_URL=https://... when needed.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ulsavam-backend.onrender.com/api/',
  );

  // Auth
  static const String register = 'auth/register/';
  static const String login = 'auth/login/';
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
  static String eventDetail(int id) => 'events/$id/';
  static String eventGoing(int id) => 'events/$id/going/';
  static String eventConfirm(int id) => 'events/$id/confirm/';
  static String eventAttendees(int id) => 'events/$id/attendees/';

  // Notifications
  static const String notifications = 'notifications/';
  static String notificationRead(int id) => 'notifications/$id/read/';
}
