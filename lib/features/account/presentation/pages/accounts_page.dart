import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/account/presentation/widgets/account_list.dart';
import 'package:enki_finance/features/account/presentation/widgets/credit_card_list.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cuentas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Cuentas'),
              Tab(text: 'Tarjetas de Crédito'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AccountList(),
            CreditCardList(),
          ],
        ),
      ),
    );
  }
}
