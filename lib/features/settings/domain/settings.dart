class Settings {
  final String currency;
  final String currencySymbol;
  final double? exchangeRate;
  final bool isDarkMode;

  Settings({
    required this.currency,
    required this.currencySymbol,
    this.exchangeRate = 1.0,
    required this.isDarkMode,
  });

  static double getRate(String code) {
    switch (code) {
      case 'IDR':
        return 16000.0;
      case 'EUR':
        return 0.92;
      case 'GBP':
        return 0.79;
      default:
        return 1.0; // USD
    }
  }

  factory Settings.defaultSettings() {
    return Settings(currency: 'USD', currencySymbol: '\$', isDarkMode: true);
  }

  Settings copyWith({
    String? currency,
    String? currencySymbol,
    double? exchangeRate,
    bool? isDarkMode,
  }) {
    return Settings(
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
