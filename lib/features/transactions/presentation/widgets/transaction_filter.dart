import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_filter_provider.dart';
import '../../../maintenance/presentation/providers/maintenance_providers.dart';
import '../providers/transaction_provider.dart';
import '../providers/current_transaction_provider.dart';

class TransactionFilter extends ConsumerStatefulWidget {
  final String userId;

  const TransactionFilter({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<TransactionFilter> createState() => _TransactionFilterState();
}

class _TransactionFilterState extends ConsumerState<TransactionFilter> {
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(transactionFilterProvider);
    ref.read(transactionFilterProvider.notifier).setUserId(widget.userId);
    _minAmountController.text = filter.minAmount?.toString() ?? '';
    _maxAmountController.text = filter.maxAmount?.toString() ?? '';
    if (filter.startDate != null && filter.endDate != null) {
      _dateRange = DateTimeRange(
        start: filter.startDate!,
        end: filter.endDate!,
      );
    }
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(transactionFilterProvider);
    final notifier = ref.read(transactionFilterProvider.notifier);
    final transactionTypesAsync = ref.watch(transactionTypesProvider);
    final categoriesAsync = ref.watch(categoriesProvider(filter.userId ?? ''));
    final subcategoriesAsync = filter.categoryId != null
        ? ref.watch(subcategoriesProvider(filter.categoryId!))
        : null;
    final jarsAsync = ref.watch(jarsProvider);
    final accountsAsync = ref.watch(accountsProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (filter.hasFilters)
                TextButton(
                  onPressed: () {
                    notifier.clearFilters();
                    _minAmountController.clear();
                    _maxAmountController.clear();
                    setState(() {
                      _dateRange = null;
                    });
                  },
                  child: const Text('Limpiar'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Range
          ListTile(
            title: const Text('Rango de Fechas'),
            subtitle: _dateRange != null
                ? Text(
                    '${DateFormat('dd/MM/yyyy').format(_dateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange!.end)}')
                : const Text('Todas las fechas'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange: _dateRange,
              );
              if (range != null) {
                setState(() {
                  _dateRange = range;
                });
                notifier.setDateRange(range.start, range.end);
              }
            },
          ),
          const Divider(),

          // Transaction Type
          transactionTypesAsync.when(
            data: (types) => DropdownButtonFormField<String>(
              value: filter.transactionTypeId,
              decoration: const InputDecoration(
                labelText: 'Tipo de Transacción',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todos'),
                ),
                ...types.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.value,
                    child: Text(entry.key),
                  );
                }),
              ],
              onChanged: notifier.setTransactionType,
            ),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 16),

          // Category
          categoriesAsync.when(
            data: (categories) {
              final filteredCategories = filter.transactionTypeId != null
                  ? categories
                      .where((c) =>
                          c.transactionTypeId == filter.transactionTypeId)
                      .toList()
                  : categories;
              return DropdownButtonFormField<String>(
                value: filter.categoryId,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Todas'),
                  ),
                  ...filteredCategories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }),
                ],
                onChanged: notifier.setCategory,
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 16),

          // Subcategory
          if (filter.categoryId != null)
            subcategoriesAsync?.when(
                  data: (subcategories) => DropdownButtonFormField<String>(
                    value: filter.subcategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Subcategoría',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ...subcategories.map((subcategory) {
                        return DropdownMenuItem(
                          value: subcategory.id,
                          child: Text(subcategory.name),
                        );
                      }),
                    ],
                    onChanged: notifier.setSubcategory,
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                ) ??
                const SizedBox.shrink(),
          if (filter.categoryId != null) const SizedBox(height: 16),

          // Jar (only for expenses)
          if (filter.transactionTypeId == 'EXPENSE')
            jarsAsync.when(
              data: (jars) => DropdownButtonFormField<String>(
                value: filter.jarId,
                decoration: const InputDecoration(
                  labelText: 'Jarra',
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Todas'),
                  ),
                  ...jars.map((jar) {
                    return DropdownMenuItem(
                      value: jar['id'] as String,
                      child: Text(jar['name'] as String),
                    );
                  }),
                ],
                onChanged: notifier.setJar,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          if (filter.transactionTypeId == 'EXPENSE') const SizedBox(height: 16),

          // Account
          accountsAsync.when(
            data: (accounts) => DropdownButtonFormField<String>(
              value: filter.accountId,
              decoration: const InputDecoration(
                labelText: 'Cuenta',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todas'),
                ),
                ...accounts.map((account) {
                  return DropdownMenuItem(
                    value: account['id'] as String,
                    child: Text(account['name'] as String),
                  );
                }),
              ],
              onChanged: notifier.setAccount,
            ),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
          const SizedBox(height: 16),

          // Amount Range
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto Mínimo',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final min = value.isEmpty ? null : double.tryParse(value);
                    final max = _maxAmountController.text.isEmpty
                        ? null
                        : double.tryParse(_maxAmountController.text);
                    notifier.setAmountRange(min, max);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _maxAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto Máximo',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final min = _minAmountController.text.isEmpty
                        ? null
                        : double.tryParse(_minAmountController.text);
                    final max = value.isEmpty ? null : double.tryParse(value);
                    notifier.setAmountRange(min, max);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Apply Button
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}
