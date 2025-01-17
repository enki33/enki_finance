import 'package:flutter/material.dart';
import 'package:enki_finance/features/settings/presentation/pages/settings_page.dart';
import 'package:enki_finance/features/maintenance/presentation/pages/maintenance_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
        );
      case '/maintenance':
        return MaterialPageRoute(
          builder: (_) => const MaintenancePage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
