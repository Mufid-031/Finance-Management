class Settings {
  final String currency;
  final String currencySymbol;
  final bool isDarkMode;

  Settings({
    required this.currency,
    required this.currencySymbol,
    required this.isDarkMode,
  });

  factory Settings.defaultSettings() {
    return Settings(currency: 'USD', currencySymbol: '\$', isDarkMode: true);
  }

  Settings copyWith({
    String? currency,
    String? currencySymbol,
    bool? isDarkMode,
  }) {
    return Settings(
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
