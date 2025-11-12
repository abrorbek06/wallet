import 'package:app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

import 'models/themes.dart';
import 'l10n/app_localizations.dart';
import 'services/locale_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedLocale = await LocaleService.loadLocale();
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
    return MaterialApp(
      title: 'Income Expense Calculator',
      theme: ThemeProvider.getTheme(ThemeProvider.currentTheme),
      home: HomeScreen(onLocaleChanged: setLocale),
      locale: _locale,
      supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        // Standard Flutter delegates (add if needed by widgets)
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
