import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:enki_finance/features/transactions/data/repositories/supabase_transaction_repository.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction.dart';
import 'package:enki_finance/core/error/failures.dart';

@GenerateMocks([SupabaseClient])
import 'supabase_transaction_repository_test.mocks.dart';

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {
  @override
  PostgrestFilterBuilder<PostgrestList> insert(Object data,
      {bool defaultToNull = true}) {
    return MockPostgrestFilterBuilder();
  }

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) {
    return MockPostgrestFilterBuilder();
  }

  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, dynamic value) {
    return MockPostgrestFilterBuilder();
  }

  @override
  PostgrestTransformBuilder<PostgrestList> order(String column,
      {bool ascending = true,
      bool nullsFirst = false,
      String? referencedTable}) {
    return MockPostgrestTransformBuilder();
  }
}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {
  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, dynamic value) {
    return this;
  }

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) {
    return MockPostgrestTransformBuilder();
  }

  @override
  PostgrestTransformBuilder<PostgrestList> order(String column,
      {bool ascending = true,
      bool nullsFirst = false,
      String? referencedTable}) {
    return MockPostgrestTransformBuilder();
  }
}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<PostgrestList> {
  @override
  PostgrestTransformBuilder<PostgrestMap> single() {
    return MockPostgrestSingleTransformBuilder();
  }

  @override
  Future<PostgrestList> execute() async {
    return [];
  }
}

class MockPostgrestSingleTransformBuilder extends Mock
    implements PostgrestTransformBuilder<PostgrestMap> {
  @override
  Future<PostgrestMap> execute() async {
    return {};
  }
}

void main() {
  late SupabaseTransactionRepository repository;
  late MockSupabaseClient mockSupabaseClient;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    repository = SupabaseTransactionRepository(mockSupabaseClient);
  });

  group('createTransaction', () {
    final testTransaction = Transaction(
      id: '1',
      userId: 'user1',
      transactionDate: DateTime(2024, 1, 1),
      amount: 100.0,
      transactionTypeId: 'type1',
      categoryId: 'cat1',
      accountId: 'acc1',
      currencyId: 'curr1',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    test('should return Right(Transaction) when the call is successful',
        () async {
      // Arrange
      when(mockSupabaseClient.from(any)).thenReturn(MockSupabaseQueryBuilder());
      when(mockSupabaseClient.from('transaction'))
          .thenReturn(MockSupabaseQueryBuilder());

      final mockFilterBuilder = MockPostgrestFilterBuilder();
      final mockTransformBuilder = MockPostgrestTransformBuilder();
      final mockSingleTransformBuilder = MockPostgrestSingleTransformBuilder();

      when(mockSupabaseClient
              .from('transaction')
              .insert(testTransaction.toJson()))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockTransformBuilder);
      when(mockTransformBuilder.single())
          .thenReturn(mockSingleTransformBuilder);
      when(mockSingleTransformBuilder.execute())
          .thenAnswer((_) async => testTransaction.toJson());

      // Act
      final result = await repository.createTransaction(testTransaction);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (transaction) => expect(transaction, equals(testTransaction)),
      );
    });

    test(
        'should return Left(ValidationFailure) when foreign key constraint fails',
        () async {
      // Arrange
      when(mockSupabaseClient.from(any)).thenReturn(MockSupabaseQueryBuilder());
      when(mockSupabaseClient.from('transaction'))
          .thenReturn(MockSupabaseQueryBuilder());

      final mockFilterBuilder = MockPostgrestFilterBuilder();
      when(mockSupabaseClient
              .from('transaction')
              .insert(testTransaction.toJson()))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select())
          .thenThrow(PostgrestException(message: 'foreign key constraint'));

      // Act
      final result = await repository.createTransaction(testTransaction);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return Left(AuthorizationFailure) when permission is denied',
        () async {
      // Arrange
      when(mockSupabaseClient.from(any)).thenReturn(MockSupabaseQueryBuilder());
      when(mockSupabaseClient.from('transaction'))
          .thenReturn(MockSupabaseQueryBuilder());
      when(mockSupabaseClient
              .from('transaction')
              .insert(testTransaction.toJson()))
          .thenThrow(PostgrestException(message: 'permission denied'));

      // Act
      final result = await repository.createTransaction(testTransaction);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthorizationFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('getTransactions', () {
    final testTransactions = [
      Transaction(
        id: '1',
        userId: 'user1',
        transactionDate: DateTime(2024, 1, 1),
        amount: 100.0,
        transactionTypeId: 'EXPENSE',
        categoryId: 'cat1',
        subcategoryId: 'subcat1',
        accountId: 'acc1',
        currencyId: 'MXN',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      Transaction(
        id: '2',
        userId: 'user1',
        transactionDate: DateTime(2024, 1, 2),
        amount: 200.0,
        transactionTypeId: 'INCOME',
        categoryId: 'cat2',
        subcategoryId: 'subcat2',
        accountId: 'acc2',
        currencyId: 'MXN',
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
      ),
    ];

    test('should return Right(List<Transaction>) when the call is successful',
        () async {
      // Arrange
      when(mockSupabaseClient.from('transaction'))
          .thenReturn(MockPostgrestFilterBuilder());
      when(mockSupabaseClient.from('transaction').select())
          .thenReturn(MockPostgrestFilterBuilder());
      when(mockSupabaseClient.from('transaction').eq('user_id', any))
          .thenReturn(MockPostgrestFilterBuilder());
      when(mockSupabaseClient
              .from('transaction')
              .order('transaction_date', ascending: false))
          .thenAnswer(
              (_) async => testTransactions.map((t) => t.toJson()).toList());

      // Act
      final result = await repository.getTransactions(userId: 'user1');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (transactions) {
          expect(transactions.length, 2);
          expect(transactions.first.id, '1');
          expect(transactions.last.id, '2');
        },
      );
    });

    test('should return Left(ServerFailure) when an error occurs', () async {
      // Arrange
      when(mockSupabaseClient.from('transaction'))
          .thenReturn(MockPostgrestFilterBuilder());
      when(mockSupabaseClient.from('transaction').select())
          .thenThrow(Exception('Server error'));

      // Act
      final result = await repository.getTransactions(userId: 'user1');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
