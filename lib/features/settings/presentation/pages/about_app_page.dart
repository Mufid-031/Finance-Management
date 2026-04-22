import 'package:finance_management/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Sleek Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative Circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: AppColors.main.withValues(alpha: 0.05),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          image: const DecorationImage(
                            image: AssetImage('logo.jpg'),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.main.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ).animate().scale(delay: 200.ms, curve: Curves.bounceIn),
                      const SizedBox(height: 20),
                      const Text(
                        "VANTAGE FINANCE",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      Text(
                        "Version 1.0.0",
                        style: TextStyle(
                          color: AppColors.grey.withValues(alpha: 0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  "The Vision",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ).animate().slideX(begin: -0.1),
                const SizedBox(height: 12),
                Text(
                  "Vantage Finance is engineered to provide comprehensive oversight of your personal financial ecosystem. By integrating advanced analytical tools and AI-driven insights, we empower you to navigate your wealth with clarity and confidence.",
                  style: TextStyle(
                    color: AppColors.grey.withValues(alpha: 0.8),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 40),

                // 3. Tech Stack Grid
                const Text(
                  "Architecture & Core",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _TechCard(
                      label: "Flutter",
                      icon: Icons.flutter_dash,
                      color: Colors.blue,
                    ),
                    _TechCard(
                      label: "Firebase",
                      icon: Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                    _TechCard(
                      label: "Vantage AI",
                      icon: Icons.auto_awesome,
                      color: Colors.teal,
                    ),
                    _TechCard(
                      label: "Riverpod",
                      icon: Icons.waves,
                      color: Colors.indigo,
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 40),

                // 4. Developer Card Premium
                const Text(
                  "The Architect",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.widgetColor,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.main,
                                width: 2,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 35,
                              backgroundColor: AppColors.backgroundColor,
                              child: Icon(
                                Icons.person,
                                color: AppColors.main,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "MUFIDD",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  "Software Architect",
                                  style: TextStyle(
                                    color: AppColors.main,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          _SocialPill(
                            icon: Icons.code_rounded,
                            label: "GitHub",
                            onTap: () =>
                                _launchUrl("https://github.com/Mufid-031"),
                          ),
                          const SizedBox(width: 10),
                          _SocialPill(
                            icon: Icons.language_rounded,
                            label: "Portfolio",
                            onTap: () =>
                                _launchUrl("https://mufid-risqi.vercel.app"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _SocialPill(
                        icon: Icons.camera_alt_rounded,
                        label: "Instagram",
                        isFullWidth: true,
                        onTap: () =>
                            _launchUrl("https://instagram.com/mufidrisqi"),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.1),

                const SizedBox(height: 50),
                Center(
                  child: Opacity(
                    opacity: 0.4,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          color: AppColors.main,
                          size: 20,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Precision Engineering for Financial Growth",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          "© 2026 VANTAGE FINANCE | MUFIDD ARCHITECT",
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _TechCard({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.widgetColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SocialPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isFullWidth;

  const _SocialPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: content)
        : Expanded(child: content);
  }
}
