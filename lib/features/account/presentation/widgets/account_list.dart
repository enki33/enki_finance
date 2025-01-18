import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/account/domain/entities/account.dart';
import 'package:enki_finance/features/account/presentation/providers/account_providers.dart';
import 'package:enki_finance/features/account/presentation/widgets/account_form_dialog.dart';

class AccountList extends ConsumerWidget {
  const AccountList({super.key});

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
                labelText: 'Buscar cuentas',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // TODO: Implement search
              },
            ),
          ),
          // Account list
          Expanded(
            child: accountsAsync.when(
              data: (accounts) => ListView.builder(
                itemCount: accounts.length + 1,
                itemBuilder: (context, index) {
                  if (index == accounts.length) {
                    return const SizedBox(height: 80);
                  }
                  final account = accounts[index];
                  return ListTile(
                    leading: Icon(
                      _getAccountIcon(account.accountTypeId),
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(account.name),
                    subtitle: Text(account.description ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${account.currentBalance.toStringAsFixed(2)}',
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
                              _showEditDialog(context, ref, account);
                            } else if (value == 'delete') {
                              _showDeleteDialog(context, ref, account);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
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

  IconData _getAccountIcon(String accountTypeId) {
    // TODO: Map account type IDs to icons
    return Icons.account_balance;
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) async {
    final account = await showDialog<Account>(
      context: context,
      builder: (context) => const AccountFormDialog(),
    );

    if (account != null) {
      ref.read(accountNotifierProvider.notifier).createAccount(account);
    }
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, Account account) async {
    final updatedAccount = await showDialog<Account>(
      context: context,
      builder: (context) => AccountFormDialog(account: account),
    );

    if (updatedAccount != null) {
      ref.read(accountNotifierProvider.notifier).updateAccount(updatedAccount);
    }
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, Account account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cuenta'),
        content: Text('¿Estás seguro de eliminar la cuenta "${account.name}"?'),
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
      ref.read(accountNotifierProvider.notifier).deleteAccount(account.id!);
    }
  }
}
