import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:enki_finance/features/transactions/data/repositories/supabase_transaction_repository.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction.dart';
import 'package:enki_finance/core/errors/failures.dart';

@GenerateMocks([SupabaseClient, PostgrestFilterBuilder])
import 'supabase_transaction_repository_test.mocks.dart';

void main() {
  late SupabaseTransactionRepository repository;
  late MockSupabaseClient mockSupabaseClient;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    repository = SupabaseTransactionRepository(mockSupabaseClient);
  });

  group('createTransaction', () {
    final testTransaction = Transaction(
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
    );

    test('should return Right(Transaction) when the call is successful',
        () async {
      // Arrange
      when(mockSupabaseClient.from('transaction'))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.insert(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.single())
          .thenAnswer((_) async => testTransaction.toJson());

      // Act
      final result = await repository.createTransaction(testTransaction);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (transaction) {
          expect(transaction.id, testTransaction.id);
          expect(transaction.amount, testTransaction.amount);
        },
      );
    });

    test(
        'should return Left(ValidationFailure) when foreign key constraint fails',
        () async {
      // Arrange
      when(mockSupabaseClient.from('transaction'))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.insert(any))
          .thenThrow(PostgrestException('foreign key constraint'));

      // Act
      final result = await repository.createTransaction(testTransaction);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return Left(UnauthorizedFailure) when permission is denied',
        () async {
      // Arrange
      when(mockSupabaseClient.from('transaction'))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.insert(any))
          .thenThrow(PostgrestException('permission denied'));

      // Act
      final result = await repository.createTransaction(testTransaction);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
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
      ),
    ];

    test('should return Right(List<Transaction>) when the call is successful',
        () async {
      // Arrange
      when(mockSupabaseClient.from('transaction'))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('user_id', any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.order('transaction_date', ascending: false))
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
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenThrow(Exception('Server error'));

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
