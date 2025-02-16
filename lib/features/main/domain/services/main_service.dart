import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../exceptions/main_exception.dart';

/// Service class for main feature business logic
class MainService {
  const MainService();

  /// Validates the app state and ensures all required services are available
  Future<void> validateAppState() async {
    try {
      print('Starting app state validation...');

      // Check if Supabase client is initialized
      try {
        print('Checking Supabase client...');
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          throw const MainException('Supabase client is not initialized');
        }
        print('Supabase client check passed');
      } catch (e) {
        print('Supabase client check failed: $e');
        throw const MainException('Supabase client is not initialized');
      }

      // Check if session is expired
      try {
        print('Checking session state...');
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          final expiresIn = session.expiresIn;
          if (expiresIn != null && expiresIn < 0) {
            throw const MainException('Session has expired');
          }
        }
        print('Session check passed');
      } catch (e) {
        print('Session check failed: $e');
        throw MainException('Session validation failed: ${e.toString()}');
      }

      // Check database connectivity using app_user table
      try {
        print('Checking database connectivity...');
        await Supabase.instance.client
            .schema('enki_finance')
            .from('app_user')
            .select('id')
            .limit(1);
        print('Database connectivity check passed');
      } catch (e) {
        print('Database connectivity check failed: $e');
        throw MainException('Database validation failed: ${e.toString()}');
      }

      print('App state validation completed successfully');
    } catch (e) {
      if (e is MainException) {
        rethrow;
      }
      print('App state validation failed: $e');
      throw MainException('App state validation failed: ${e.toString()}');
    }
  }

  /// Initializes required services and configurations
  Future<void> initialize() async {
    try {
      print('Starting initialization...');

      print('Initializing local storage...');
      await _initializeLocalStorage();

      print('Initializing deep linking...');
      await _initializeDeepLinking();

      print('Initialization complete');
    } catch (e, stackTrace) {
      print('Initialization failed at: $e');
      print('Stack trace: $stackTrace');
      throw MainException('Failed to initialize app: ${e.toString()}');
    }
  }

  Future<void> _initializeLocalStorage() async {
    try {
      print('Getting SharedPreferences instance...');
      final prefs = await SharedPreferences.getInstance();

      print('Verifying storage access...');
      await prefs.setString('_test_key', 'test_value');
      final testValue = prefs.getString('_test_key');
      if (testValue != 'test_value') {
        throw const MainException('Storage verification failed');
      }
      await prefs.remove('_test_key');
      print('Local storage initialized successfully');
    } catch (e) {
      print('Local storage initialization failed: $e');
      throw MainException(
          'Failed to initialize local storage: ${e.toString()}');
    }
  }

  Future<void> _initializeDeepLinking() async {
    try {
      print('Creating AppLinks instance...');
      final appLinks = AppLinks();

      // Get the initial link if the app was launched from a link
      try {
        print('Checking for initial deep link...');
        final initialLink = await appLinks.getInitialLink();
        if (initialLink != null) {
          print('Initial deep link found: $initialLink');
          _handleDeepLink(initialLink);
        }
      } catch (e) {
        print('Failed to get initial deep link: $e');
        // Don't throw here as it's not critical
      }

      // Listen for deep links while the app is running
      print('Setting up deep link listener...');
      appLinks.uriLinkStream.listen(
        (uri) {
          print('Deep link received: $uri');
          _handleDeepLink(uri);
        },
        onError: (err) {
          print('Deep linking error: $err');
          // Don't throw here as it's an async stream
        },
      );
      print('Deep linking initialized successfully');
    } catch (e) {
      print('Deep linking initialization failed: $e');
      // Don't throw here as deep linking is not critical for app functionality
      print('Continuing without deep linking support');
    }
  }

  void _handleDeepLink(Uri uri) {
    // TODO: Implement deep link handling
    print('Deep link received: $uri');
  }
}
