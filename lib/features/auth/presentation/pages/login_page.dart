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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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
            top: -100,
            right: -50,
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
                        title: "Welcome Back",
                        subtitle: "Securely login to your Fintrack account",
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                      const SizedBox(height: 40),
                      AuthTextField(
                        controller: emailController,
                        label: "Email Address",
                        hintText: 'name@example.com',
                        prefixIcon: Icons.email_outlined,
                        textInputAction: TextInputAction.next,
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: passwordController,
                        label: "Password",
                        hintText: '••••••••',
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
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: AppColors.main,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 24),
                      AuthButton(
                        isLoading: state.isLoading,
                        text: "Sign In",
                        onPressed: () async {
                          if (emailController.text.isNotEmpty &&
                              passwordController.text.isNotEmpty) {
                            await notifier.login(
                              emailController.text,
                              passwordController.text,
                            );
                          } else {
                            ErrorUtils.showError(
                              context,
                              "Please enter both email and password",
                            );
                          }
                        },
                      ).animate().fadeIn(delay: 500.ms).scaleXY(begin: 0.9),
                      const SizedBox(height: 32),
                      _buildDivider().animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: 32),
                      _buildGoogleButton(state.isLoading, () async {
                        await notifier.loginWithGoogle();
                      }).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
                      const SizedBox(height: 24),
                      AuthFooter(
                        text: "Don't have an account?",
                        actionText: "Create Account",
                        onTap: () => context.push('/register'),
                      ).animate().fadeIn(delay: 800.ms),
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "SOCIAL LOGIN",
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
        ),
      ],
    );
  }

  Widget _buildGoogleButton(bool isLoading, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.widgetColor.withValues(alpha: 0.3),
        ),
        onPressed: isLoading ? null : onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.network(
              'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
              height: 22,
            ),
            const SizedBox(width: 12),
            const Text(
              "Continue with Google",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
