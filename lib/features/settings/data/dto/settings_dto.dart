import 'package:finance_management/features/settings/domain/settings.dart';

class SettingsDTO {
  final String currency;
  final String currencySymbol;
  final double exchangeRate;
  final bool isDarkMode;

  SettingsDTO({
    required this.currency,
    required this.currencySymbol,
    this.exchangeRate = 1.0,
    required this.isDarkMode,
  });

  factory SettingsDTO.fromMap(Map<String, dynamic> map) {
    return SettingsDTO(
      currency: map['currency'] ?? 'USD',
      currencySymbol: map['currencySymbol'] ?? '\$',
      exchangeRate: map['exchangeRate'] ?? 1.0,
      isDarkMode: map['isDarkMode'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'currencySymbol': currencySymbol,
      'exchangeRate': exchangeRate,
      'isDarkMode': isDarkMode,
    };
  }

  factory SettingsDTO.fromDomain(Settings domain) {
    return SettingsDTO(
      currency: domain.currency,
      currencySymbol: domain.currencySymbol,
      exchangeRate: domain.exchangeRate ?? 1.0,
      isDarkMode: domain.isDarkMode,
    );
  }

  Settings toDomain() {
    return Settings(
      currency: currency,
      currencySymbol: currencySymbol,
      exchangeRate: exchangeRate,
      isDarkMode: isDarkMode,
    );
  }
}
