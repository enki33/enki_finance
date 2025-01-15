import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  // App information
  static String get appName => dotenv.env['APP_NAME'] ?? 'Enki Finance';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get defaultCurrency => dotenv.env['DEFAULT_CURRENCY'] ?? 'MXN';

  // Supabase configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Feature flags
  static bool get enableNotifications =>
      dotenv.env['ENABLE_NOTIFICATIONS']?.toLowerCase() == 'true';
  static bool get enableMultiCurrency =>
      dotenv.env['ENABLE_MULTI_CURRENCY']?.toLowerCase() == 'true';
  static bool get enableRecurringTransactions =>
      dotenv.env['ENABLE_RECURRING_TRANSACTIONS']?.toLowerCase() == 'true';
  static bool get enableExportToExcel =>
      dotenv.env['ENABLE_EXPORT_TO_EXCEL']?.toLowerCase() == 'true';

  // App settings
  static int get defaultNotificationMinutes =>
      int.parse(dotenv.env['DEFAULT_NOTIFICATION_MINUTES'] ?? '30');
}
