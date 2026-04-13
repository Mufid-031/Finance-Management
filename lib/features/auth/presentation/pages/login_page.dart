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
    // Di dalam build() LoginPage
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.user != null) {
        context.go('/main');
      }

      // Gunakan Utility yang sudah kita buat
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ErrorUtils.showError(context, next.errorMessage!);

        // Opsional: Reset error di notifier agar tidak muncul dua kali saat rebuild
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    final state = ref.watch(authNotifierProvider);
    final notifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: SingleChildScrollView(
            // Tambahkan ini agar aman saat keyboard muncul
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AuthHeader(
                  title: "Sign In",
                  subtitle: "Sign in to your account",
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  controller: emailController,
                  label: "Email",
                  hintText: 'Enter your email',
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: passwordController,
                  label: "Password",
                  hintText: 'Enter your password',
                  obscureText: true,
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: AppColors.main),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
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

                // --- BAGIAN GOOGLE LOGIN ---
                const SizedBox(height: 20),
                _buildDivider(),
                const SizedBox(height: 20),

                _buildGoogleButton(state.isLoading, () async {
                  await notifier.loginWithGoogle();
                }),

                // ---------------------------
                AuthFooter(
                  text: "Don't have an account?",
                  actionText: "Sign Up",
                  onTap: () => context.push('/register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.grey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "OR",
            style: TextStyle(color: AppColors.grey, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.grey)),
      ],
    );
  }

  Widget _buildGoogleButton(bool isLoading, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: AppColors.white.withValues(alpha: 0.1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        icon: SvgPicture.network(
          'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
          height: 20,
          placeholderBuilder: (context) => const CircularProgressIndicator(),
        ),
        label: const Text(
          "Continue with Google",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
