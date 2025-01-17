import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/category_list.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/subcategory_list.dart';

class MaintenancePage extends ConsumerWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mantenimiento'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Categorías'),
              Tab(text: 'Subcategorías'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CategoryList(),
            SubcategoryList(),
          ],
        ),
      ),
    );
  }
}
