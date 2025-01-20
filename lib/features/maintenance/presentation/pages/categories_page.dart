import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/category_list.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/subcategory_list.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    print('DEBUG: CategoriesPage initState');
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        print('DEBUG: Tab changed to index ${_tabController.index}');
      }
    });
  }

  @override
  void dispose() {
    print('DEBUG: CategoriesPage dispose');
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: CategoriesPage build called');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            print('DEBUG: Tab tapped with index $index');
          },
          tabs: const [
            Tab(text: 'Categorías'),
            Tab(text: 'Subcategorías'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Builder(builder: (context) {
            print('DEBUG: Building Categories tab');
            return const CategoryList();
          }),
          Builder(builder: (context) {
            print('DEBUG: Building Subcategories tab');
            return const SubcategoryList();
          }),
        ],
      ),
    );
  }
}
