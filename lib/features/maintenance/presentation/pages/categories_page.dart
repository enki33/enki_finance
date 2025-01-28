import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/category_list.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/subcategory_list.dart';
import 'package:enki_finance/core/providers/current_user_id_provider.dart';
import 'package:enki_finance/features/maintenance/domain/entities/category.dart';

// Selected category provider
final selectedCategoryProvider = StateProvider<Category?>((ref) => null);

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
        // Only reset selected category when switching back to categories tab
        if (_tabController.index == 0) {
          print('DEBUG: Resetting selected category');
          ref.read(selectedCategoryProvider.notifier).state = null;
        }
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
    final selectedCategory = ref.watch(selectedCategoryProvider);
    print('DEBUG: Current selectedCategory: ${selectedCategory?.id}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        bottom: TabBar(
          controller: _tabController,
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
            final userId = ref.watch(currentUserIdProvider);
            return CategoryList(
              userId: userId,
              onCategorySelected: (category) {
                print(
                    'DEBUG: Category selected in CategoriesPage: ${category.id}');
                // Update selectedCategoryProvider
                ref.read(selectedCategoryProvider.notifier).state = category;
                print('DEBUG: Updated selectedCategoryProvider');
                print('DEBUG: Switching to subcategories tab');
                _tabController.animateTo(1);
              },
            );
          }),
          Builder(builder: (context) {
            print('DEBUG: Building Subcategories tab');
            if (selectedCategory?.id == null || selectedCategory == null) {
              return const Center(
                child:
                    Text('Selecciona una categoría para ver sus subcategorías'),
              );
            }
            print(
                'DEBUG: Showing subcategories for category: ${selectedCategory.id}');
            return SubcategoryList(categoryId: selectedCategory.id!);
          }),
        ],
      ),
    );
  }
}
