import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, UserAttributes;
import '../../../../core/providers/supabase_provider.dart';
import '../../../settings/domain/entities/currency.dart';
import '../../domain/entities/auth_user.dart';
import '../providers/auth_provider.dart';
import '../../../settings/data/repositories/currency_repository_provider.dart';
import '../../data/repositories/auth_repository_provider.dart';

class UserInfoPage extends HookConsumerWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Información de Usuario'),
      ),
      body: authState.when(
        data: (user) => _UserInfoContent(user: user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _UserInfoContent extends HookConsumerWidget {
  const _UserInfoContent({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isEditing = useState(false);
    final isPasswordVisible = useState(false);
    final firstNameController = useTextEditingController(text: user?.firstName);
    final lastNameController = useTextEditingController(text: user?.lastName);
    final passwordController = useTextEditingController();
    final selectedCurrency = useState<Currency?>(null);

    final currencyRepository = ref.watch(currencyRepositoryProvider);
    final currencies = useState<List<Currency>>([]);

    useEffect(() {
      Future<void> loadCurrencies() async {
        try {
          debugPrint('Loading currencies for user: ${user?.id}');
          final loadedCurrencies = await currencyRepository.getCurrencies();
          currencies.value = loadedCurrencies;

          // Load user's default currency
          if (user?.id != null) {
            debugPrint('Loading default currency for user: ${user?.id}');
            final defaultCurrency =
                await currencyRepository.getUserDefaultCurrency(
              userId: user!.id,
            );
            debugPrint('Default currency loaded: $defaultCurrency');
            selectedCurrency.value = defaultCurrency;
          }
        } catch (e) {
          debugPrint('Error loading currencies: $e');
          if (e is PostgrestException) {
            debugPrint('PostgreSQL Error Details:');
            debugPrint('  Message: ${e.message}');
            debugPrint('  Code: ${e.code}');
            debugPrint('  Details: ${e.details}');
            debugPrint('  Hint: ${e.hint}');
          }
        }
      }

      loadCurrencies();
      return null;
    }, [user]);

    Future<void> saveChanges() async {
      if (formKey.currentState?.validate() ?? false) {
        try {
          // Update user's default currency if changed
          if (selectedCurrency.value != null && user?.id != null) {
            await currencyRepository.updateUserDefaultCurrency(
              userId: user!.id,
              currencyId: selectedCurrency.value!.id,
            );
          }

          // Update user profile information
          if (user?.id != null) {
            final authRepository = ref.read(authRepositoryProvider);
            await authRepository.updateUserProfile(
              userId: user!.id,
              firstName: firstNameController.text,
              lastName: lastNameController.text,
            );

            // Update password if provided
            if (passwordController.text.isNotEmpty) {
              await ref.read(supabaseClientProvider).auth.updateUser(
                    UserAttributes(
                      password: passwordController.text,
                    ),
                  );
              // Clear password field after successful update
              passwordController.clear();
            }
          }

          // Refresh the user's data after updating
          await ref.read(authProvider.notifier).refreshUser();

          isEditing.value = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Changes saved successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving changes: $e')),
          );
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Email (non-editable)
            TextFormField(
              initialValue: user?.email,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
              enabled: isEditing.value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
              enabled: isEditing.value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    isPasswordVisible.value = !isPasswordVisible.value;
                  },
                ),
              ),
              enabled: isEditing.value,
              obscureText: !isPasswordVisible.value,
              validator: (value) {
                if (value != null && value.isNotEmpty && value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Currency>(
              value: selectedCurrency.value,
              decoration: const InputDecoration(
                labelText: 'Default Currency',
                border: OutlineInputBorder(),
              ),
              items: currencies.value.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text('${currency.code} - ${currency.name}'),
                );
              }).toList(),
              onChanged: isEditing.value
                  ? (Currency? newValue) {
                      selectedCurrency.value = newValue;
                    }
                  : null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('User ID'),
              subtitle: Text(user?.id ?? 'N/A'),
            ),
            ListTile(
              title: const Text('Created At'),
              subtitle: Text(user?.createdAt.toString() ?? 'N/A'),
            ),
            ListTile(
              title: const Text('Last Updated'),
              subtitle: Text(user?.updatedAt.toString() ?? 'N/A'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isEditing.value) {
                    saveChanges();
                  } else {
                    isEditing.value = true;
                  }
                },
                child:
                    Text(isEditing.value ? 'Save Changes' : 'Edit Information'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
