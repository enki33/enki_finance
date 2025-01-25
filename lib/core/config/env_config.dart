import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EnvConfig {
  static final _secureStorage = FlutterSecureStorage();
  static encrypt.Key? _encryptionKey;
  static encrypt.IV? _iv;

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    await _initializeEncryption();
  }

  static Future<void> _initializeEncryption() async {
    final keyString = await _secureStorage.read(key: 'encryption_key');
    if (keyString == null) {
      final key = encrypt.Key.fromSecureRandom(32);
      final iv = encrypt.IV.fromSecureRandom(16);
      await _secureStorage.write(key: 'encryption_key', value: key.base64);
      await _secureStorage.write(key: 'encryption_iv', value: iv.base64);
      _encryptionKey = key;
      _iv = iv;
    } else {
      _encryptionKey = encrypt.Key.fromBase64(keyString);
      final ivString = await _secureStorage.read(key: 'encryption_iv');
      _iv = encrypt.IV.fromBase64(ivString!);
    }
  }

  static String _decrypt(String encryptedValue) {
    if (_encryptionKey == null || _iv == null) {
      throw StateError('Encryption not initialized');
    }
    final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey!));
    return encrypter.decrypt64(encryptedValue, iv: _iv!);
  }

  static String _encrypt(String value) {
    if (_encryptionKey == null || _iv == null) {
      throw StateError('Encryption not initialized');
    }
    final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey!));
    return encrypter.encrypt(value, iv: _iv!).base64;
  }

  // App information
  static String get appName => dotenv.env['APP_NAME'] ?? 'Enki Finance';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get defaultCurrency => dotenv.env['DEFAULT_CURRENCY'] ?? 'MXN';

  // Supabase configuration with encryption
  static Future<String> get supabaseUrl async {
    final encrypted = await _secureStorage.read(key: 'supabase_url');
    if (encrypted == null) {
      final url = dotenv.env['SUPABASE_URL'] ?? '';
      if (url.isNotEmpty) {
        await _secureStorage.write(
          key: 'supabase_url',
          value: _encrypt(url),
        );
      }
      return url;
    }
    return _decrypt(encrypted);
  }

  static Future<String> get supabaseAnonKey async {
    final encrypted = await _secureStorage.read(key: 'supabase_anon_key');
    if (encrypted == null) {
      final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      if (key.isNotEmpty) {
        await _secureStorage.write(
          key: 'supabase_anon_key',
          value: _encrypt(key),
        );
      }
      return key;
    }
    return _decrypt(encrypted);
  }

  // Feature flags
  static bool get enableNotifications =>
      dotenv.env['ENABLE_NOTIFICATIONS']?.toLowerCase() == 'true';
  static bool get enableMultiCurrency =>
      dotenv.env['ENABLE_MULTI_CURRENCY']?.toLowerCase() == 'true';
  static bool get enableRecurringTransactions =>
      dotenv.env['ENABLE_RECURRING_TRANSACTIONS']?.toLowerCase() == 'true';
  static bool get enableExportToExcel =>
      dotenv.env['ENABLE_EXPORT_TO_EXCEL']?.toLowerCase() == 'true';

  // App settings with secure storage
  static Future<int> get defaultNotificationMinutes async {
    final value = await _secureStorage.read(key: 'notification_minutes');
    return int.parse(
        value ?? dotenv.env['DEFAULT_NOTIFICATION_MINUTES'] ?? '30');
  }

  static Future<void> setDefaultNotificationMinutes(int minutes) async {
    await _secureStorage.write(
      key: 'notification_minutes',
      value: minutes.toString(),
    );
  }
}
