import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/jar_list.dart';

class JarsPage extends ConsumerWidget {
  const JarsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jarras'),
      ),
      body: const JarList(),
    );
  }
}
