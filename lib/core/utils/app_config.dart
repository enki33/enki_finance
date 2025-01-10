import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Enki Finance';
  static const String appVersion = '0.1.0';

  // Jar percentages
  static const double necessitiesPercentage = 0.55;
  static const double longTermInvestmentPercentage = 0.10;
  static const double savingsPercentage = 0.10;
  static const double educationPercentage = 0.10;
  static const double entertainmentPercentage = 0.10;
  static const double donationsPercentage = 0.05;

  // Supabase configuration
  static const String supabaseUrl = String.fromEnvironment(
    'https://wzizrjgayseskstrcijz.supabase.co',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6aXpyamdheXNlc2tzdHJjaWp6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU3MzQ1ODQsImV4cCI6MjA1MTMxMDU4NH0.5yNO-HtKf3DoQn_dXh4aUwUJsmYe-SEGHLvcya7Ac3A',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  // PowerSync configuration
  static const String powersyncSecret = String.fromEnvironment(
    'POWERSYNC_SECRET',
    defaultValue: 'YOUR_POWERSYNC_SECRET',
  );

  // Feature flags
  static const bool enableNotifications = true;
  static const bool enableMultiCurrency = true;
  static const bool enableRecurringTransactions = true;
  static const bool enableExportToExcel = true;

  // Default currency
  static const String defaultCurrency = 'MXN';

  // App settings
  static const int syncIntervalMinutes = 5;
  static const int maxOfflineDays = 30;
  static const int defaultNotificationMinutes = 1440; // 24 hours

  // Debug settings
  static bool get isDebug => kDebugMode;
  static bool get enableLogging => kDebugMode;
}
