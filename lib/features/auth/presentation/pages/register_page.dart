import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/error_utils.dart';
import 'package:finance_management/features/auth/presentation/widgets/auth_button.dart';
import 'package:finance_management/features/auth/presentation/widgets/auth_footer.dart';
import 'package:finance_management/features/auth/presentation/widgets/auth_header.dart';
import 'package:finance_management/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_management/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.user != null) {
        context.go('/main');
      }

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ErrorUtils.showError(context, next.errorMessage!);
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    final state = ref.watch(authNotifierProvider);
    final notifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Background Decorative Circle
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.main.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AuthHeader(
                        title: "Create Account",
                        subtitle: "Start your journey with Fintrack today",
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                      const SizedBox(height: 40),
                      AuthTextField(
                        controller: emailController,
                        label: "Email Address",
                        hintText: 'name@example.com',
                        prefixIcon: Icons.email_outlined,
                        textInputAction: TextInputAction.next,
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: passwordController,
                        label: "Password",
                        hintText: 'Minimum 6 characters',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: !isPasswordVisible,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => isPasswordVisible = !isPasswordVisible,
                          ),
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.grey,
                            size: 20,
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                      const SizedBox(height: 32),
                      AuthButton(
                        isLoading: state.isLoading,
                        text: "Create Account",
                        onPressed: () async {
                          if (emailController.text.isNotEmpty &&
                              passwordController.text.isNotEmpty) {
                            await notifier.register(
                              emailController.text,
                              passwordController.text,
                            );
                          } else {
                            ErrorUtils.showError(
                              context,
                              "Please fill in all fields",
                            );
                          }
                        },
                      ).animate().fadeIn(delay: 400.ms).scaleXY(begin: 0.9),
                      const SizedBox(height: 32),
                      AuthFooter(
                        text: "Already have an account?",
                        actionText: "Sign In",
                        onTap: () => context.push('/login'),
                      ).animate().fadeIn(delay: 500.ms),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
