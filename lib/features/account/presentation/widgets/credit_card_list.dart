import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/account/domain/entities/account.dart';
import 'package:enki_finance/features/account/domain/entities/credit_card_details.dart';
import 'package:enki_finance/features/account/presentation/providers/account_providers.dart';
import 'package:enki_finance/features/account/presentation/widgets/credit_card_form_dialog.dart';

class CreditCardList extends ConsumerWidget {
  const CreditCardList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountNotifierProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar tarjetas',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // TODO: Implement search
              },
            ),
          ),
          // Credit card list
          Expanded(
            child: accountsAsync.when(
              data: (accounts) {
                final creditCards = accounts
                    .where((a) => a.accountTypeId == 'CREDIT_CARD')
                    .toList();
                return ListView.builder(
                  itemCount: creditCards.length + 1,
                  itemBuilder: (context, index) {
                    if (index == creditCards.length) {
                      return const SizedBox(height: 80);
                    }
                    final account = creditCards[index];
                    return _CreditCardTile(account: account);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) async {
    final creditCard = await showDialog<(Account, CreditCardDetails)>(
      context: context,
      builder: (context) => const CreditCardFormDialog(),
    );

    if (creditCard != null) {
      final (account, details) = creditCard;
      await ref.read(accountNotifierProvider.notifier).createAccount(account);
      await ref
          .read(creditCardNotifierProvider(account.id!).notifier)
          .createCreditCardDetails(details);
    }
  }
}

class _CreditCardTile extends ConsumerWidget {
  final Account account;

  const _CreditCardTile({required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(creditCardNotifierProvider(account.id!));

    return detailsAsync.when(
      data: (details) {
        if (details == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      account.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Eliminar'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(context, ref);
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, ref);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'Balance actual:',
                  value: '\$${account.currentBalance.toStringAsFixed(2)}',
                ),
                _DetailRow(
                  label: 'Límite de crédito:',
                  value: '\$${details.creditLimit.toStringAsFixed(2)}',
                ),
                _DetailRow(
                  label: 'Crédito disponible:',
                  value:
                      '\$${(details.creditLimit + account.currentBalance).toStringAsFixed(2)}',
                ),
                _DetailRow(
                  label: 'Tasa de interés:',
                  value: '${details.currentInterestRate}%',
                ),
                _DetailRow(
                  label: 'Fecha de corte:',
                  value: 'Día ${details.cutOffDay}',
                ),
                _DetailRow(
                  label: 'Fecha límite de pago:',
                  value: 'Día ${details.paymentDueDay}',
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: ${error.toString()}'),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) async {
    final creditCard = await showDialog<(Account, CreditCardDetails)>(
      context: context,
      builder: (context) => CreditCardFormDialog(account: account),
    );

    if (creditCard != null) {
      final (updatedAccount, updatedDetails) = creditCard;
      await ref
          .read(accountNotifierProvider.notifier)
          .updateAccount(updatedAccount);
      await ref
          .read(creditCardNotifierProvider(account.id!).notifier)
          .updateCreditCardDetails(updatedDetails);
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tarjeta'),
        content:
            Text('¿Estás seguro de eliminar la tarjeta "${account.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(creditCardNotifierProvider(account.id!).notifier)
          .deleteCreditCardDetails();
      await ref
          .read(accountNotifierProvider.notifier)
          .deleteAccount(account.id!);
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
