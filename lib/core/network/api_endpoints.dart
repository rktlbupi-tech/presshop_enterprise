class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ─────────────────────────────────────────────────
  static const String login = 'auth/loginEnterpriseEmployee';
  static const String signup = 'auth/registerEnterpriseEmployee';
  static const String refreshToken = 'auth/refreshToken';
  static const String logout = 'auth/logout';
  static const String sendOtp = 'hopper/sendEmailOTP';
  static const String verifyOtp = 'hopper/verifyEmailOTP';
  static const String forgotPassword = 'auth/forgotPassword';
  static const String resetPassword = 'auth/resetPassword';
  static const String changePassword = 'users/changePassword';
  static const String deleteAccount = 'hopper/verifyAndDeleteAccount';

  // ── Profile ──────────────────────────────────────────────
  static const String getProfile = 'hopper/getEnterpriseUserProfile';
  static const String updateProfile = 'hopper/updateEnterpriseUserProfile';

  // ── Attendance ───────────────────────────────────────────
  static const String checkIn = 'enterprise/attendance/check-in';
  static const String checkOut = 'enterprise/attendance/check-out';
  static const String attendanceLog = 'enterprise/attendance/log';

  // ── Attendance (worker app — self-scoped clock in/out) ────
  static const String attendanceToday = 'enterprise/app/attendance/today';
  static const String attendancePunch = 'enterprise/app/attendance/punch';

  // ── Attendance log screen (worker app — self-scoped) ──────
  // See docs/api/attendance-log.md
  static const String attendanceSummary = 'enterprise/app/attendance/summary';
  static const String attendanceAppLog = 'enterprise/app/attendance/log';
  static const String attendanceIssues = 'enterprise/app/attendance/issues';

  // ── Duties screen (worker app — self-scoped) ──────────────
  // See docs/api/duties-screen.md
  static const String dutiesCurrent = 'enterprise/app/duties/current';
  static const String dutiesUpcoming = 'enterprise/app/duties/upcoming';
  static const String dutiesTodayTasks = 'enterprise/app/duties/today-tasks';
  static const String dutiesHistory = 'enterprise/app/duties/history';
  static const String dutiesHandoverReport =
      'enterprise/app/duties/handover-report';

  // ── Claim expenses screen (worker app — self-scoped) ──────
  // See docs/api/claim-expenses.md
  static const String claimsSummary = 'enterprise/app/claims/summary';
  static const String claims = 'enterprise/app/claims';

  // ── Media upload (returns a hosted file URL) ──────────────
  static const String uploadUserMedia = 'hopper/uploadUserMedia';

  // ── Tasks ────────────────────────────────────────────────
  static const String tasks = 'enterprise/tasks';
  static const String taskDetails = 'enterprise/tasks/'; // + id

  // ── Documents ────────────────────────────────────────────
  static const String documents = 'enterprise/documents';

  // ── Earnings ─────────────────────────────────────────────
  static const String earnings = 'enterprise/earnings';

  // ── Map / Heatmap ────────────────────────────────────────
  static const String heatmapLocation = 'enterprise/heatmap/location';
  static const String heatmapWorkers = 'enterprise/heatmap/workers';
  static const String heatmapAlerts = 'enterprise/heatmap/alerts';

  // ── SOS ──────────────────────────────────────────────────
  static const String sosStart = 'enterprise/sos/start';
  static const String sosStop = 'enterprise/sos/stop';
  static const String sosMe = 'enterprise/sos/me';

  // ── Notifications ────────────────────────────────────────
  static const String fcmToken = 'enterprise/devices/fcm-token';
  static const String notifications = 'enterprise/notifications';

  // ── Feed ─────────────────────────────────────────────────
  static const String feed = 'enterprise/feed/assigned';

  // ── Deep Links ───────────────────────────────────────────
  static const String resolveDeepLink = 'api/deep-links/';
  static const String matchDevice = 'api/deep-links/match-device';

  // ── Settings & CMS ───────────────────────────────────────
  static const String getGeneralMgmtApp = 'hopper/getGenralMgmtApp';
  static const String getCategory = 'hopper/getCategory';
  static const String contactUs = 'hopper/Addcontact_us';
  // static const String deleteAccount = 'hopper/verifyAndDeleteAccount';
}
