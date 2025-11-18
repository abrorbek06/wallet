import 'package:app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

import 'models/themes.dart';
import 'l10n/app_localizations.dart';
import 'services/locale_service.dart';
import 'services/currency_service.dart';
import 'services/exchange_rate_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedLocale = await LocaleService.loadLocale();
  await CurrencyService.init();
  // Fetch exchange rate in background (don't block app startup)
  ExchangeRateService.fetchExchangeRate();
  runApp(MyApp(savedLocale: savedLocale));
}

class MyApp extends StatefulWidget {
  final Locale? savedLocale;
  const MyApp({super.key, this.savedLocale});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('uz');

  @override
  void initState() {
    super.initState();
    if (widget.savedLocale != null) _locale = widget.savedLocale!;
  }

  void setLocale(Locale locale) async {
    if (!mounted) return;
    await LocaleService.saveLocale(locale);
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Currency>(
      valueListenable: CurrencyService.notifier,
      builder: (context, currency, _) {
        return MaterialApp(
          title: AppLocalizations.of(context).t('app_title'),
          theme: ThemeProvider.getTheme(ThemeProvider.currentTheme),
          home: HomeScreen(onLocaleChanged: setLocale),
          locale: _locale,
          supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            // Standard Flutter delegates required for Material/Cupertino widgets
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Resolve to a supported locale (fallback to English) when the
          // requested locale isn't directly supported by the delegates.
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return supportedLocales.first;
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }
            return const Locale('en');
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
