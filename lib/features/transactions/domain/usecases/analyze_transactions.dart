class AnalyzeTransactions {
  final ITransactionRepository repository;
  final TransactionAnalysisService analysisService;

  AnalyzeTransactions(this.repository, this.analysisService);

  Future<TransactionAnalysis> call(TransactionFilter filter) async {
    final transactions = await repository.getTransactions(filter);
    return analysisService.analyze(transactions);
  }
}
