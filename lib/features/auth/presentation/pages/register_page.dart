import 'package:finance_management/features/auth/presentation/widgets/auth_button.dart';
import 'package:finance_management/features/auth/presentation/widgets/auth_footer.dart';
import 'package:finance_management/features/auth/presentation/widgets/auth_header.dart';
import 'package:finance_management/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.user != null) {
        context.go('/main');
      }

      if (next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final state = ref.watch(authNotifierProvider);
    final notifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthHeader(title: "Sign Up", subtitle: "Create your account"),
              SizedBox(height: 20),
              AuthTextField(controller: emailController, label: "Email", hintText: 'Enter your email'),
              SizedBox(height: 16),
              AuthTextField(
                controller: passwordController,
                label: "Password",
                hintText: 'Enter your password',
                obscureText: true,
              ),
              SizedBox(height: 5),
              SizedBox(height: 5),
              AuthButton(
                isLoading: state.isLoading,
                text: "Register",
                onPressed: () async {
                  await notifier.register(
                    emailController.text,
                    passwordController.text,
                  );
                },
              ),
              SizedBox(height: 20),
              AuthFooter(
                text: "Already have an account?",
                actionText: "Sign In",
                onTap: () => context.push('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
