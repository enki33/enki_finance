import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_filter_provider.dart';

class DateRangeFilter extends ConsumerWidget {
  const DateRangeFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterProvider);
    final notifier = ref.read(transactionFilterProvider.notifier);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(
                  'Rango de Fechas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (filter.startDate != null || filter.endDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => notifier.clearDateRange(),
                    tooltip: 'Limpiar fechas',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: filter.startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: filter.endDate ?? DateTime.now(),
                      );
                      if (date != null) {
                        notifier.setDateRange(date, filter.endDate);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Desde',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        filter.startDate != null
                            ? dateFormat.format(filter.startDate!)
                            : 'Seleccionar',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: filter.endDate ?? DateTime.now(),
                        firstDate: filter.startDate ?? DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        notifier.setDateRange(
                          filter.startDate,
                          DateTime(date.year, date.month, date.day, 23, 59, 59),
                        );
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hasta',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        filter.endDate != null
                            ? dateFormat.format(filter.endDate!)
                            : 'Seleccionar',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickDateButton(
                    label: 'Hoy',
                    onPressed: () => notifier.setToday(),
                    isSelected: _isToday(filter.startDate, filter.endDate),
                  ),
                  const SizedBox(width: 8),
                  _QuickDateButton(
                    label: 'Esta Semana',
                    onPressed: () => notifier.setThisWeek(),
                    isSelected: _isThisWeek(filter.startDate, filter.endDate),
                  ),
                  const SizedBox(width: 8),
                  _QuickDateButton(
                    label: 'Este Mes',
                    onPressed: () => notifier.setThisMonth(),
                    isSelected: _isThisMonth(filter.startDate, filter.endDate),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    return start.year == now.year &&
        start.month == now.month &&
        start.day == now.day &&
        end.year == now.year &&
        end.month == now.month &&
        end.day == now.day;
  }

  bool _isThisWeek(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return start.year == weekStart.year &&
        start.month == weekStart.month &&
        start.day == weekStart.day &&
        end.year == now.year &&
        end.month == now.month &&
        end.day == now.day;
  }

  bool _isThisMonth(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    return start.year == now.year &&
        start.month == now.month &&
        start.day == 1 &&
        end.year == now.year &&
        end.month == now.month &&
        end.day == now.day;
  }
}

class _QuickDateButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  const _QuickDateButton({
    required this.label,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceVariant,
        foregroundColor: isSelected
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      child: Text(label),
    );
  }
}
