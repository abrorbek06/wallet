import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'welcome_back': 'Welcome Back!',
      'overview': "Here's your financial overview",
      'settings': 'Settings',
      'send_feedback': 'Send Feedback',
      'configure_telegram': 'Configure Telegram',
      'save_test': 'Save & Test',
      'telegram_configured': 'Telegram configured',
      'sending_feedback': 'Sending feedback...',
      'feedback_sent': 'Feedback sent — thank you!',
      'enter_feedback': 'Please enter your feedback',
      'telegram_not_configured':
          'Please configure your Telegram bot token and chat id to receive feedback.',
      'configure': 'Configure',
      'rate_app': 'Rate App',
      'how_rate': 'How would you rate the app?',
      'thank_you_rating': 'Thank you for your rating!',
      'failed_send_rating': 'Failed to send rating:',
      'home': 'Home',
      'daily': 'Daily',
      'statistics': 'Statistics',
      'today_transactions': "Today's Transactions",
      'previous_days': 'Previous Days',
      'language': 'Language',
      'select_language': 'Select language',
      'uzbek': 'Uzbek',
      'russian': 'Russian',
      'english': 'English',
    },
    'uz': {
      'welcome_back': 'Xush kelibsiz!',
      'overview': 'Moliya holatingiz shu yerda',
      'settings': 'Sozlamalar',
      'send_feedback': 'Fikr bildirish',
      'configure_telegram': 'Telegram sozlash',
      'save_test': 'Saqlash va Sinash',
      'telegram_configured': 'Telegram sozlandi',
      'sending_feedback': 'Fikr yuborilmoqda...',
      'feedback_sent': 'Fikringiz uchun rahmat!',
      'enter_feedback': 'Iltimos, fikringizni kiriting',
      'telegram_not_configured':
          'Fikrlarni qabul qilish uchun Telegram bot token va chat id ni sozlang.',
      'configure': 'Sozlash',
      'rate_app': 'Ilovani baholang',
      'how_rate': 'Ilovani qanday baholaysiz?',
      'thank_you_rating': 'Baholangiz uchun rahmat!',
      'failed_send_rating': 'Yuborishda xatolik:',
      'home': 'Uy',
      'daily': 'Kunlik',
      'statistics': 'Statistika',
      'today_transactions': 'Bugungi tranzaksiyalar',
      'previous_days': 'Oldingi kunlar',
      'language': 'Til',
      'select_language': 'Tilni tanlang',
      'uzbek': 'Oʻzbek',
      'russian': 'Rus',
      'english': 'Ingliz',
    },
    'ru': {
      'welcome_back': 'С возвращением!',
      'overview': 'Обзор ваших финансов',
      'settings': 'Настройки',
      'send_feedback': 'Отправить отзыв',
      'configure_telegram': 'Настроить Telegram',
      'save_test': 'Сохранить и проверить',
      'telegram_configured': 'Telegram настроен',
      'sending_feedback': 'Отправка отзыва...',
      'feedback_sent': 'Спасибо за отзыв!',
      'enter_feedback': 'Пожалуйста, введите отзыв',
      'telegram_not_configured':
          'Пожалуйста, настройте токен бота и chat id в Telegram для получения отзывов.',
      'configure': 'Настроить',
      'rate_app': 'Оценить приложение',
      'how_rate': 'Как вы оцените приложение?',
      'thank_you_rating': 'Спасибо за оценку!',
      'failed_send_rating': 'Не удалось отправить оценку:',
      'home': 'Главная',
      'daily': 'Ежедневно',
      'statistics': 'Статистика',
      'today_transactions': 'Транзакции сегодня',
      'previous_days': 'Предыдущие дни',
      'language': 'Язык',
      'select_language': 'Выберите язык',
      'uzbek': 'Узбекский',
      'russian': 'Русский',
      'english': 'Английский',
    },
  };

  String t(String key) {
    final map =
        _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
    return map[key] ?? key;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'uz', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
