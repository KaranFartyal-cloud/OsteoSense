import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Localization service for managing language switching and translations
class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();

  Locale _currentLocale = const Locale('en');

  LocalizationService._internal();

  factory LocalizationService() {
    return _instance;
  }

  /// Get current locale
  Locale get currentLocale => _currentLocale;

  /// Get current language code
  String get languageCode => _currentLocale.languageCode;

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  /// Get AppLocalizations for current locale
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  /// Set language to English
  void setEnglish() {
    _currentLocale = const Locale('en');
  }

  /// Set language to Hindi
  void setHindi() {
    _currentLocale = const Locale('hi');
  }

  /// Set locale dynamically
  void setLocale(String languageCode) {
    switch (languageCode) {
      case 'en':
        setEnglish();
        break;
      case 'hi':
        setHindi();
        break;
      default:
        setEnglish();
    }
  }

  /// Get display name for language
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      default:
        return 'English';
    }
  }

  /// Check if Hindi language is supported
  static bool get isHindiSupported => true;

  /// Check if English language is supported
  static bool get isEnglishSupported => true;

  /// Get list of available languages with codes
  static List<Map<String, String>> getAvailableLanguages() {
    return [
      {'code': 'en', 'name': 'English'},
      {'code': 'hi', 'name': 'हिंदी (Hindi)'},
    ];
  }

  /// Get locale delegate for MaterialApp
  static LocalizationsDelegate<AppLocalizations> localizationsDelegates() {
    return AppLocalizations.delegate;
  }

  /// Get supported locales list for MaterialApp
  static List<Locale> getSupportedLocalesForApp() {
    return supportedLocales;
  }

  /// Format date in current locale
  String formatDate(DateTime date) {
    // This would use intl package for proper date formatting
    // For now, using basic formatting
    return date.toString();
  }

  /// Format currency in current locale
  String formatCurrency(double amount) {
    // Currency formatting based on locale
    if (_currentLocale.languageCode == 'hi') {
      return '₹${amount.toStringAsFixed(2)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Format number in current locale
  String formatNumber(num number) {
    return number.toString();
  }
}

/// Extension to easily access localized strings
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
