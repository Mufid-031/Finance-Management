import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsState {
  final Settings settings;
  final bool isLoading;
  final String? errorMessage;

  SettingsState({
    required this.settings,
    this.isLoading = false,
    this.errorMessage,
  });
}
