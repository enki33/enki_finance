import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/settings.dart';
import '../providers/settings_providers.dart';
import '../utils/settings_error_messages.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    // Show error snackbar when settings update fails
    ref.listen<AsyncValue<Settings>>(
      settingsNotifierProvider,
      (_, next) {
        next.whenOrNull(
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(SettingsErrorMessages.getSnackBarMessage(error)),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    // Retry the last settings update
                    ref.invalidate(settingsNotifierProvider);
                  },
                ),
                duration: const Duration(seconds: 4),
                showCloseIcon: true,
              ),
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: settingsAsync.when(
        data: (settings) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: ListView(
            key: ValueKey(settings.hashCode),
            children: [
              _buildUserInfoTile(context),
              const Divider(),
              _buildNotificationsTile(ref, settings),
              if (settings.notificationsEnabled)
                _buildNotificationDaysTile(ref, settings),
              const Divider(),
              _buildMultiCurrencyTile(ref, settings),
              _buildRecurringTransactionsTile(ref, settings),
              _buildExcelExportTile(ref, settings),
            ],
          ),
        ),
        loading: () => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
        error: (error, _) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        SettingsErrorMessages.getUserFriendlyMessage(error),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.invalidate(settingsProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserInfoTile(BuildContext context) {
    return Hero(
      tag: 'user-info-hero',
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: animation.drive(
              Tween<double>(begin: 1.0, end: 1.0).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            ),
            child: toHeroContext.widget,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('User Information'),
          subtitle: const Text('View and edit your account details'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.pushNamed('user-info'),
        ),
      ),
    );
  }

  Widget _buildNotificationsTile(WidgetRef ref, Settings settings) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: SwitchListTile(
        title: const Text('Notifications'),
        subtitle: const Text('Enable or disable notifications'),
        value: settings.notificationsEnabled,
        onChanged: (value) {
          ref.read(settingsNotifierProvider.notifier).updateSettings(
                settings.copyWith(notificationsEnabled: value),
              );
        },
      ),
    );
  }

  Widget _buildNotificationDaysTile(WidgetRef ref, Settings settings) {
    return AnimatedOpacity(
      opacity: settings.notificationsEnabled ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: ListTile(
        title: const Text('Notification Days'),
        subtitle: Text('${settings.notificationAdvanceDays} days in advance'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: settings.notificationAdvanceDays > 0
                  ? () {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .updateSettings(
                            settings.copyWith(
                              notificationAdvanceDays:
                                  settings.notificationAdvanceDays - 1,
                            ),
                          );
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: settings.notificationAdvanceDays < 30
                  ? () {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .updateSettings(
                            settings.copyWith(
                              notificationAdvanceDays:
                                  settings.notificationAdvanceDays + 1,
                            ),
                          );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiCurrencyTile(WidgetRef ref, Settings settings) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: SwitchListTile(
        title: const Text('Multi-Currency Support'),
        subtitle: const Text('Enable handling multiple currencies'),
        value: settings.multiCurrencyEnabled,
        onChanged: (value) {
          ref.read(settingsNotifierProvider.notifier).updateSettings(
                settings.copyWith(multiCurrencyEnabled: value),
              );
        },
      ),
    );
  }

  Widget _buildRecurringTransactionsTile(WidgetRef ref, Settings settings) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: SwitchListTile(
        title: const Text('Recurring Transactions'),
        subtitle: const Text('Enable automatic recurring transactions'),
        value: settings.recurringTransactionsEnabled,
        onChanged: (value) {
          ref.read(settingsNotifierProvider.notifier).updateSettings(
                settings.copyWith(recurringTransactionsEnabled: value),
              );
        },
      ),
    );
  }

  Widget _buildExcelExportTile(WidgetRef ref, Settings settings) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: SwitchListTile(
        title: const Text('Excel Export'),
        subtitle: const Text('Enable exporting data to Excel'),
        value: settings.exportToExcelEnabled,
        onChanged: (value) {
          ref.read(settingsNotifierProvider.notifier).updateSettings(
                settings.copyWith(exportToExcelEnabled: value),
              );
        },
      ),
    );
  }
}
