import 'package:flutter/foundation.dart';
import '../config/env_config.dart';

/// Application configuration constants and settings
class AppConfig {
  const AppConfig._();

  // Jar percentages (constants that don't need to be in .env)
  static const double necessitiesPercentage = 0.55;
  static const double longTermInvestmentPercentage = 0.10;
  static const double savingsPercentage = 0.10;
  static const double educationPercentage = 0.10;
  static const double entertainmentPercentage = 0.10;
  static const double donationsPercentage = 0.05;

  // App information (retrieved from environment)
  static String get appName => EnvConfig.appName;
  static String get appVersion => EnvConfig.appVersion;
  static String get defaultCurrency => EnvConfig.defaultCurrency;

  // Feature flags (retrieved from environment)
  static bool get enableNotifications => EnvConfig.enableNotifications;
  static bool get enableMultiCurrency => EnvConfig.enableMultiCurrency;
  static bool get enableRecurringTransactions =>
      EnvConfig.enableRecurringTransactions;
  static bool get enableExportToExcel => EnvConfig.enableExportToExcel;

  // App settings (retrieved from environment)
  static Future<int> get defaultNotificationMinutes =>
      EnvConfig.defaultNotificationMinutes;

  // Debug settings (not sensitive, can be hardcoded)
  static bool get isDebug => kDebugMode;
  static bool get enableLogging => kDebugMode;

  // Supabase configuration (retrieved from environment)
  static Future<String> get supabaseUrl => EnvConfig.supabaseUrl;
  static Future<String> get supabaseAnonKey => EnvConfig.supabaseAnonKey;
}
