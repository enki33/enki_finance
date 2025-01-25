import '../../domain/exceptions/settings_exception.dart';

class SettingsErrorMessages {
  static String getUserFriendlyMessage(Object error) {
    if (error is SettingNotFoundException) {
      return 'Unable to load your settings. Please try again later.';
    }

    if (error is InvalidSettingValueException) {
      if (error.message.contains('notification_advance_days')) {
        return 'Notification days must be between 0 and 30 days.';
      }
      if (error.message.contains('currency')) {
        return 'The selected currency is not supported. Please choose a different one.';
      }
      return 'The setting value you entered is not valid. Please check and try again.';
    }

    if (error is SystemInitializationException) {
      if (error.message.contains('database')) {
        return 'Unable to connect to the database. Please check your internet connection and try again.';
      }
      if (error.message.contains('migration')) {
        return 'System update in progress. Please try again in a few minutes.';
      }
      return 'System settings are not properly initialized. Please contact support.';
    }

    if (error.toString().contains('User not authenticated')) {
      return 'Please sign in to manage your settings.';
    }

    if (error.toString().contains('Loading authentication state')) {
      return 'Loading your account information...';
    }

    if (error.toString().contains('permission')) {
      return 'You don\'t have permission to modify these settings. Please contact your administrator.';
    }

    if (error.toString().contains('timeout')) {
      return 'The operation timed out. Please check your internet connection and try again.';
    }

    if (error.toString().contains('concurrent')) {
      return 'Another update is in progress. Please wait a moment and try again.';
    }

    return 'An unexpected error occurred. Please try again later.';
  }

  static String getSnackBarMessage(Object error) {
    if (error.toString().contains('Failed to update')) {
      return 'Failed to save your settings. Please try again.';
    }

    if (error.toString().contains('network')) {
      return 'Network error. Please check your connection and try again.';
    }

    if (error.toString().contains('timeout')) {
      return 'The operation took too long. Please try again.';
    }

    if (error.toString().contains('permission')) {
      return 'You don\'t have permission to make this change.';
    }

    if (error.toString().contains('validation')) {
      return 'The value you entered is not valid. Please check and try again.';
    }

    if (error.toString().contains('concurrent')) {
      return 'Another update is in progress. Please wait a moment.';
    }

    return 'Unable to complete the operation. Please try again.';
  }
}
