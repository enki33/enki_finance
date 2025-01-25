import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:gotrue/gotrue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enki_finance/features/main/domain/services/main_service.dart';
import 'package:enki_finance/features/main/domain/exceptions/main_exception.dart';

import 'main_service_test.mocks.dart';

@GenerateMocks([SupabaseClient, GoTrueClient])
void main() {
  late MainService mainService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mainService = const MainService();

    // Set up default mocks
    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(mockSupabaseClient.from(any)).thenReturn(mockQueryBuilder);
  });

  group('validateAppState', () {
    test('should complete successfully when all checks pass', () async {
      // Arrange
      when(mockGoTrueClient.currentSession).thenReturn(null);
      final mockFilterBuilder = MockPostgrestFilterBuilder();
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.execute()).thenAnswer((_) async => []);

      // Act & Assert
      await expectLater(mainService.validateAppState(), completes);
    });

    test('should throw MainException when session is expired', () async {
      // Arrange
      final expiredSession = Session(
        accessToken: 'token',
        tokenType: 'bearer',
        expiresIn: -1,
        refreshToken: 'refresh',
        user: User(
          id: 'id',
          appMetadata: const {},
          userMetadata: const {},
          aud: 'aud',
          createdAt: DateTime.now().toString(),
        ),
      );
      when(mockGoTrueClient.currentSession).thenReturn(expiredSession);

      // Act & Assert
      await expectLater(
        mainService.validateAppState(),
        throwsA(isA<MainException>().having(
          (e) => e.message,
          'message',
          contains('Session has expired'),
        )),
      );
    });

    test('should throw MainException when database check fails', () async {
      // Arrange
      when(mockSupabaseClient.from(any)).thenThrow(
        const PostgrestException(message: 'Database error'),
      );

      // Act & Assert
      await expectLater(
        mainService.validateAppState(),
        throwsA(isA<MainException>().having(
          (e) => e.message,
          'message',
          contains('Database validation failed'),
        )),
      );
    });
  });

  group('initialize', () {
    test('should complete successfully when all initializations pass',
        () async {
      // Arrange
      TestWidgetsFlutterBinding.ensureInitialized();
      final mockPrefs = MockSharedPreferences();
      when(SharedPreferences.getInstance()).thenAnswer((_) async => mockPrefs);

      // Act & Assert
      await expectLater(mainService.initialize(), completes);
    });

    test('should throw MainException when local storage initialization fails',
        () async {
      // Arrange
      TestWidgetsFlutterBinding.ensureInitialized();
      when(SharedPreferences.getInstance())
          .thenThrow(Exception('Storage error'));

      // Act & Assert
      await expectLater(
        mainService.initialize(),
        throwsA(isA<MainException>().having(
          (e) => e.message,
          'message',
          contains('Failed to initialize local storage'),
        )),
      );
    });
  });
}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {
  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select(
      [String? columns = '*']) {
    return MockPostgrestFilterBuilder();
  }
}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> limit(int count,
      {String? referencedTable}) {
    return this;
  }

  @override
  Future<List<Map<String, dynamic>>> execute() async => [];
}

class MockSharedPreferences extends Mock implements SharedPreferences {}
