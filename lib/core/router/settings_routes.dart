import 'package:finance_management/features/settings/presentation/pages/general_settings_page.dart';
import 'package:go_router/go_router.dart';

final settingsRoutes = [
  GoRoute(
    path: '/settings/general',
    name: 'general-settings',
    builder: (context, state) => const GeneralSettingsPage(),
  ),
];
