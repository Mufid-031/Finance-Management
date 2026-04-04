import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/features/auth/presentation/widgets/auth_button.dart';
import 'package:finance_management/features/auth/presentation/widgets/auth_footer.dart';
import 'package:finance_management/features/auth/presentation/widgets/auth_header.dart';
import 'package:finance_management/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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
              AuthHeader(title: "Sign In", subtitle: "Sign in to your account"),
              SizedBox(height: 20),
              AuthTextField(
                controller: emailController,
                label: "Email",
                hintText: 'Enter your email',
              ),
              SizedBox(height: 16),
              AuthTextField(
                controller: passwordController,
                label: "Password",
                hintText: 'Enter your password',
                obscureText: true,
              ),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.push('/forgot-password');
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: AppColors.main),
                  ),
                ),
              ),
              SizedBox(height: 5),
              AuthButton(
                isLoading: state.isLoading,
                text: "Login",
                onPressed: () async {
                  await notifier.login(
                    emailController.text,
                    passwordController.text,
                  );
                },
              ),
              AuthFooter(
                text: "Don't have an account?",
                actionText: "Sign Up",
                onTap: () => context.push('/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
