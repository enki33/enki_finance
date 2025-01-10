import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powersync/powersync.dart';
import 'package:powersync/sqlite3.dart';
import 'core/core.dart';
import 'core/providers/database_provider.dart';
import 'shared/data/schema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  final db = await container.read(databaseProvider.future);
  final connector = SupabaseConnector(
    client: Supabase.instance.client,
    schema: schema,
  );
  await connector.connect(db);

  runApp(
    ProviderScope(
      providerContainer: container,
      child: const EnkiFinanceApp(),
    ),
  );
}

class EnkiFinanceApp extends ConsumerWidget {
  const EnkiFinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
