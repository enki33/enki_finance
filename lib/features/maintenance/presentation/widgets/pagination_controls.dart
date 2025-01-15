import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginationControls extends ConsumerWidget {
  final StateProvider<int> pageProvider;
  final StateProvider<int> totalPagesProvider;

  const PaginationControls({
    super.key,
    required this.pageProvider,
    required this.totalPagesProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(pageProvider);
    final totalPages = ref.watch(totalPagesProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: currentPage > 1
              ? () => ref.read(pageProvider.notifier).state = 1
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1
              ? () => ref.read(pageProvider.notifier).state = currentPage - 1
              : null,
        ),
        Text('$currentPage de $totalPages'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages
              ? () => ref.read(pageProvider.notifier).state = currentPage + 1
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: currentPage < totalPages
              ? () => ref.read(pageProvider.notifier).state = totalPages
              : null,
        ),
      ],
    );
  }
}
