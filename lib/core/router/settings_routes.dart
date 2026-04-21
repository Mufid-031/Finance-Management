import 'package:finance_management/features/settings/presentation/pages/general_settings_page.dart';
import 'package:finance_management/features/settings/presentation/pages/appearance_settings_page.dart';
import 'package:finance_management/features/settings/presentation/pages/profile_detail_page.dart';
import 'package:go_router/go_router.dart';

final settingsRoutes = [
  GoRoute(
    path: '/settings/general',
    name: 'general-settings',
    builder: (context, state) => const GeneralSettingsPage(),
  ),
  GoRoute(
    path: '/settings/appearance',
    name: 'appearance-settings',
    builder: (context, state) => const AppearanceSettingsPage(),
  ),
  GoRoute(
    path: '/settings/profile',
    name: 'profile-detail',
    builder: (context, state) => const ProfileDetailPage(),
  ),
];
