import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env_config.dart';
import 'core/routing/app_router.dart';
import 'core/utils/app_theme.dart';
import 'core/providers/theme_provider.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize environment variables
    await EnvConfig.initialize();

    // Initialize Supabase
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );

    runApp(const ProviderScope(child: App()));
  } catch (e) {
    debugPrint('Initialization error: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Error initializing app: ${e.toString()}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Enki Finance',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
