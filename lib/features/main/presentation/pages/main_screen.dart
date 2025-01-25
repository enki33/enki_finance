import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../auth/auth.dart';
import '../../domain/services/main_service_provider.dart';
import '../../domain/exceptions/main_exception.dart';

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isInitializing = useState(true);
    final hasError = useState(false);

    // Initialize and validate app state
    useEffect(() {
      Future<void> initializeApp() async {
        try {
          isInitializing.value = true;
          hasError.value = false;
          final mainService = ref.read(mainServiceProvider);
          await mainService.initialize();
          await mainService.validateAppState();
        } catch (error) {
          hasError.value = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: initializeApp,
              ),
            ),
          );
        } finally {
          isInitializing.value = false;
        }
      }

      initializeApp();
      return null;
    }, []);

    if (isInitializing.value) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: authState.when(
          data: (user) => Text(
            user != null ? 'Welcome, ${user.firstName}' : 'Enki Finance',
          ),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Enki Finance'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Maintenance',
            onPressed: () => context.go('/settings/maintenance'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.goNamed('login');
              }
            },
          ),
        ],
      ),
      body: hasError.value
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Failed to initialize app',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      isInitializing.value = true;
                      hasError.value = false;
                      ref.invalidate(mainServiceProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : child,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.goNamed('home');
              break;
            case 1:
              context.goNamed('jars');
              break;
            case 2:
              context.goNamed('transactions');
              break;
            case 3:
              context.goNamed('accounts');
              break;
            case 4:
              context.goNamed('reports');
              break;
          }
        },
        selectedIndex: _calculateSelectedIndex(context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: 'Jars',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/jars')) {
      return 1;
    }
    if (location.startsWith('/transactions')) {
      return 2;
    }
    if (location.startsWith('/accounts')) {
      return 3;
    }
    if (location.startsWith('/reports')) {
      return 4;
    }
    return 0;
  }
}
