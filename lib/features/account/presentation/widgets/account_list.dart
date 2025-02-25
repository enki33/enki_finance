import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/core/providers/supabase_provider.dart';
import 'package:enki_finance/features/account/domain/entities/account.dart';
import 'package:enki_finance/features/account/presentation/providers/account_providers.dart';
import 'package:enki_finance/features/account/presentation/widgets/account_form_dialog.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/pagination_controls.dart';

class AccountList extends ConsumerStatefulWidget {
  const AccountList({super.key});

  @override
  ConsumerState<AccountList> createState() => _AccountListState();
}

class _AccountListState extends ConsumerState<AccountList> {
  @override
  void initState() {
    super.initState();
    print('DEBUG: AccountList initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('DEBUG: AccountList post frame callback');
      ref.invalidate(filteredAccountsProvider);
    });
  }

  @override
  void dispose() {
    print('DEBUG: AccountList dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: AccountList build start');
    final accountsAsync = ref.watch(filteredAccountsProvider);
    print('DEBUG: AccountList provider state: $accountsAsync');
    final showActiveItems = ref.watch(showActiveAccountsProvider);

    print('AccountList - Current state: ${accountsAsync.toString()}');

    return Stack(
      children: [
        Column(
          children: [
            // Search and filter bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Buscar cuentas',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        print('AccountList - Search query changed: $value');
                        ref.read(accountSearchQueryProvider.notifier).state =
                            value;
                        ref.read(accountPageProvider.notifier).state = 1;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Mostrar activos'),
                      Switch(
                        value: showActiveItems,
                        onChanged: (value) {
                          print('AccountList - Active filter changed: $value');
                          ref.read(showActiveAccountsProvider.notifier).state =
                              value;
                          ref.read(accountPageProvider.notifier).state = 1;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Account list
            Expanded(
              child: accountsAsync.when(
                data: (accounts) {
                  print('AccountList - Received ${accounts.length} accounts');
                  return accounts.isEmpty
                      ? const Center(
                          child: Text('No hay cuentas disponibles'),
                        )
                      : ListView.builder(
                          itemCount: accounts.length + 1,
                          itemBuilder: (context, index) {
                            if (index == accounts.length) {
                              return const SizedBox(height: 80);
                            }
                            final account = accounts[index];
                            print(
                                'AccountList - Building account item: ${account['name']}');
                            return ListTile(
                              leading: const Icon(Icons.account_balance),
                              title: Text(account['name'] as String),
                              subtitle: account['description'] != null
                                  ? Text(account['description'] as String)
                                  : null,
                              trailing: PopupMenuButton(
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
                            );
                          },
                        );
                },
                loading: () {
                  print('AccountList - In loading state');
                  return const Center(child: CircularProgressIndicator());
                },
                error: (error, stack) {
                  print('AccountList - Error: $error');
                  print('AccountList - Stack trace: $stack');
                  return Center(
                    child: Text('Error: ${error.toString()}'),
                  );
                },
              ),
            ),
            // Pagination controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PaginationControls(
                pageProvider: accountPageProvider,
                totalPagesProvider: accountTotalPagesProvider,
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _showAddDialog(context, ref),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) async {
    final account = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AccountFormDialog(),
    );

    if (account != null) {
      ref.read(isSavingProvider.notifier).state = true;
      try {
        final client = ref.read(supabaseClientProvider);
        await client.from('account').insert(account);
        ref.invalidate(filteredAccountsProvider);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        ref.read(isSavingProvider.notifier).state = false;
      }
    }
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, Map<String, dynamic> account) async {
    final updatedAccount = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AccountFormDialog(account: account),
    );

    if (updatedAccount != null) {
      ref.read(isSavingProvider.notifier).state = true;
      try {
        final client = ref.read(supabaseClientProvider);
        await client
            .from('account')
            .update(updatedAccount)
            .eq('id', account['id'] as String);
        ref.invalidate(filteredAccountsProvider);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        ref.read(isSavingProvider.notifier).state = false;
      }
    }
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, Map<String, dynamic> account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cuenta'),
        content: Text(
            '¿Estás seguro que deseas eliminar la cuenta "${account['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(isDeletingProvider.notifier).state = true;
      try {
        final client = ref.read(supabaseClientProvider);
        await client.from('account').delete().eq('id', account['id'] as String);
        ref.invalidate(filteredAccountsProvider);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        ref.read(isDeletingProvider.notifier).state = false;
      }
    }
  }
}
