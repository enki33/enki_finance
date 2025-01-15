import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchFilterBar extends ConsumerWidget {
  final String searchHint;
  final StateProvider<String> searchProvider;
  final StateProvider<bool> showSystemItemsProvider;
  final StateProvider<int> pageProvider;

  const SearchFilterBar({
    super.key,
    required this.searchHint,
    required this.searchProvider,
    required this.showSystemItemsProvider,
    required this.pageProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSystemItems = ref.watch(showSystemItemsProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                ref.read(searchProvider.notifier).state = value;
                ref.read(pageProvider.notifier).state =
                    1; // Reset to first page
              },
            ),
          ),
          const SizedBox(width: 8),
          ToggleButtons(
            isSelected: [showSystemItems],
            onPressed: (index) {
              ref.read(showSystemItemsProvider.notifier).state =
                  !showSystemItems;
              ref.read(pageProvider.notifier).state = 1; // Reset to first page
            },
            children: const [
              Tooltip(
                message: 'Mostrar elementos del sistema',
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.settings),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
