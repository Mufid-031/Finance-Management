import 'package:finance_management/core/theme/app_colors.dart';
import 'package:finance_management/core/utils/error_utils.dart';
import 'package:finance_management/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileDetailPage extends ConsumerStatefulWidget {
  const ProfileDetailPage({super.key});

  @override
  ConsumerState<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends ConsumerState<ProfileDetailPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  bool isEditing = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final profile = ref.read(userProfileNotifierProvider).profile;
    if (profile != null) {
      nameController.text = profile.displayName ?? "";
      emailController.text = profile.email ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileNotifierProvider);
    final notifier = ref.read(userProfileNotifierProvider.notifier);
    final profile = state.profile;

    // Listen for errors
    ref.listen(userProfileNotifierProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ErrorUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit_outlined),
            onPressed: () {
              setState(() {
                if (!isEditing) _loadInitialData();
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: AppColors.main.withValues(
                            alpha: 0.1,
                          ),
                          backgroundImage:
                              profile?.photoUrl != null &&
                                  profile!.photoUrl!.isNotEmpty
                              ? NetworkImage(profile.photoUrl!)
                              : null,
                          child:
                              profile?.photoUrl == null ||
                                  profile!.photoUrl!.isEmpty
                              ? Text(
                                  profile?.displayName?[0].toUpperCase() ??
                                      profile?.email?[0].toUpperCase() ??
                                      "U",
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: AppColors.main,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        if (isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => notifier.pickAndUploadImage(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.main,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.backgroundColor,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  if (isEditing) ...[
                    _buildTextField(
                      "Display Name",
                      nameController,
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      "Email Address",
                      emailController,
                      Icons.email_outlined,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.main,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          // 1. Update Profile (Name)
                          await notifier.updateProfile(
                            displayName: nameController.text,
                          );

                          // 2. Update Email if changed (Firebase will send verification)
                          if (emailController.text != profile?.email) {
                            await notifier.updateEmail(emailController.text);
                            if (context.mounted) {
                              ErrorUtils.showSnackBar(
                                context: context,
                                message: "Verification email sent to ${emailController.text}",
                                icon: Icons.mark_email_read_outlined,
                              );
                            }
                          }

                          // 3. Refresh and exit editing
                          await notifier.fetchProfile();
                          setState(() => isEditing = false);

                          if (context.mounted) {
                            ErrorUtils.showSuccess(context, "Profile updated successfully!");
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ErrorUtils.showError(context, "Update failed: $e");
                          }
                        }
                      },
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else ...[
                    _buildInfoCard(
                      "Display Name",
                      profile?.displayName ?? "Guest",
                    ),
                    const SizedBox(height: 15),
                    _buildInfoCard(
                      "Email Address",
                      profile?.email ?? "Not logged in",
                    ),
                    const SizedBox(height: 15),
                    _buildInfoCard("Account ID", profile?.id ?? "---"),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.main),
            filled: true,
            fillColor: AppColors.widgetColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.widgetColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
