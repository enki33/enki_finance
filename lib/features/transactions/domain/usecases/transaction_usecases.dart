class GetTransactions {
  final ITransactionRepository repository;

  GetTransactions(this.repository);

  Future<List<Transaction>> call(TransactionFilter filter) {
    return repository.getTransactions(filter);
  }
}

class CreateTransaction {
  final ITransactionRepository repository;
  final TransactionValidator validator;

  CreateTransaction(this.repository, this.validator);

  Future<Transaction> call(Transaction transaction) async {
    // Validate transaction
    final validationResult = validator.validate(transaction);
    if (!validationResult.isValid) {
      throw TransactionValidationException(validationResult.errors);
    }

    return repository.createTransaction(transaction);
  }
}

// Similar use cases for update, delete, and get by id
