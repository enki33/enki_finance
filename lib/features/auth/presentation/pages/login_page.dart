import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
//import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../providers/auth_provider.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enki Finance',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SupaEmailAuth(
                  onSignInComplete: (response) {
                    ref
                        .read(authProvider.notifier)
                        .handleAuthResponse(response);
                  },
                  onSignUpComplete: (response) {
                    ref
                        .read(authProvider.notifier)
                        .handleAuthResponse(response);
                  },
                  metadataFields: [
                    MetaDataField(
                      prefixIcon: const Icon(Icons.person_outline),
                      label: 'Nombre',
                      key: 'first_name',
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    MetaDataField(
                      prefixIcon: const Icon(Icons.person_outline),
                      label: 'Apellido',
                      key: 'last_name',
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Por favor ingresa tu apellido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
