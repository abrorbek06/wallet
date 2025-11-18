import 'package:app/screens/settings/widgets/category_section.dart';
import 'package:app/screens/settings/widgets/info_section.dart';
import 'package:app/screens/settings/widgets/theme_section.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/currency_service.dart';
import '../../models/models.dart';
import '../../models/themes.dart';
import '../../functions/category_managment.dart';
import '../../services/telegram_service.dart';
import '../../services/telegram_sync_service.dart';
import '../../models/storage.dart';

class SettingsScreen extends StatefulWidget {
  final String currentTheme;
  final Function(String) onThemeChanged;
  final Function(Category) onAddCategory;
  final Function(String, bool) onRemoveCategory;
  final void Function(Locale)? onLocaleChanged;

  const SettingsScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.onAddCategory,
    required this.onRemoveCategory,
    this.onLocaleChanged,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _telegramAutoSync = false;
  final TextEditingController _telegramUrlController = TextEditingController();
  @override
  void initState() {
    super.initState();
    CategoryManager.loadSavedCategories();
    _loadTelegramSettings();
  }

  void _loadTelegramSettings() async {
    final enabled = await loadTelegramAutoSync();
    final url = await loadTelegramBotUrl();
    setState(() {
      _telegramAutoSync = enabled;
      _telegramUrlController.text = url ?? 'http://127.0.0.1:5001';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: ThemeProvider.getBackgroundColor(),
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).t('settings'),
          style: TextStyle(
            color: ThemeProvider.getTextColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ThemeSection(
            currentTheme: widget.currentTheme,
            onThemeChanged: (val) {
              widget.onThemeChanged(val);
              ThemeProvider.setTheme(val);
              setState(() {});
            },
          ),
          const SizedBox(height: 24),
          // Currency selection
          ListTile(
            tileColor: ThemeProvider.getCardColor(),
            title: Text(
              AppLocalizations.of(context).t('currency'),
              style: TextStyle(color: ThemeProvider.getTextColor()),
            ),
            subtitle: Text(
              CurrencyService.instance.currency == Currency.UZS
                  ? "so'm"
                  : r'USD',
              style: TextStyle(color: Colors.grey[400]),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onTap: _showCurrencyDialog,
          ),
          const SizedBox(height: 24),
          CategorySection(
            onAddCategory: (cat) {
              widget.onAddCategory(cat);
              setState(() {});
            },
            onRemoveCategory: (id, isIncome) {
              widget.onRemoveCategory(id, isIncome);
              setState(() {});
            },
          ),
          const SizedBox(height: 24),
          // Language selection
          ListTile(
            tileColor: ThemeProvider.getCardColor(),
            title: Text(
              AppLocalizations.of(context).t('language'),
              style: TextStyle(color: ThemeProvider.getTextColor()),
            ),
            subtitle: Text(
              _getCurrentLanguageName(context),
              style: TextStyle(color: Colors.grey[400]),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onTap: _showLanguageDialog,
          ),
          const SizedBox(height: 24),
          InfoSection(onRateApp: _rateApp, onHelpPressed: _showFeedbackDialog),
          const SizedBox(height: 24),
          // Telegram Bot Sync
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ThemeProvider.getCardColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Telegram Sync',
                      style: TextStyle(
                        color: ThemeProvider.getTextColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: _telegramAutoSync,
                      onChanged: (v) async {
                        await saveTelegramAutoSync(v);
                        setState(() => _telegramAutoSync = v);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _telegramUrlController,
                  decoration: InputDecoration(
                    labelText: 'Bot Server URL',
                    hintText: 'http://127.0.0.1:5001',
                  ),
                  onSubmitted: (val) async {
                    await saveTelegramBotUrl(val.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved Telegram bot URL')),
                    );
                  },
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final sync = TelegramSyncService(
                          baseUrl: _telegramUrlController.text.trim(),
                        );
                        final added = await sync.fetchAndMergeTransactions();
                        if (added > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Imported $added transactions from Telegram',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No new transactions found'),
                            ),
                          );
                        }
                      },
                      child: Text('Sync Now'),
                    ),
                    SizedBox(width: 12),
                    TextButton(
                      onPressed: () async {
                        await saveTelegramBotUrl(
                          _telegramUrlController.text.trim(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Saved Telegram bot URL')),
                        );
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentLanguageName(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    switch (code) {
      case 'ru':
        return AppLocalizations.of(context).t('russian');
      case 'en':
        return AppLocalizations.of(context).t('english');
      case 'uz':
      default:
        return AppLocalizations.of(context).t('uzbek');
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: AlertDialog(
            backgroundColor: ThemeProvider.getCardColor(),
            title: Text(
              AppLocalizations.of(context).t('select_language'),
              style: TextStyle(color: ThemeProvider.getTextColor()),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context).t('uzbek')),
                  onTap: () {
                    widget.onLocaleChanged?.call(Locale('uz'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).t('russian')),
                  onTap: () {
                    widget.onLocaleChanged?.call(Locale('ru'));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).t('english')),
                  onTap: () {
                    widget.onLocaleChanged?.call(Locale('en'));
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeProvider.getCardColor(),
          title: Text(
            AppLocalizations.of(context).t('select_currency'),
            style: TextStyle(color: ThemeProvider.getTextColor()),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('USD'),
                onTap: () async {
                  await CurrencyService.instance.setCurrency(Currency.USD);
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("so'm"),
                onTap: () async {
                  await CurrencyService.instance.setCurrency(Currency.UZS);
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // About dialog helper removed (not used here). Use showAboutAppDialog when needed.

  void _rateApp() {
    // Show star-rating dialog and send rating to Telegram
    final commentController = TextEditingController();
    int rating = 5;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: ThemeProvider.getCardColor(),
              title: Text(
                AppLocalizations.of(context).t('rate_app'),
                style: TextStyle(color: ThemeProvider.getTextColor()),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context).t('how_rate'),
                    style: TextStyle(color: ThemeProvider.getTextColor()),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        icon: Icon(
                          starIndex <= rating ? Icons.star : Icons.star_border,
                          color:
                              starIndex <= rating ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () => setState(() => rating = starIndex),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(
                        context,
                      ).t('optional_comment'),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).t('cancel')),
                ),
                TextButton(
                  onPressed: () async {
                    final comment = commentController.text.trim();
                    final msg =
                        'App Rating: $rating/5\n${comment.isNotEmpty ? 'Comment: $comment\n' : ''}';
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context).t('sending_feedback'),
                          ),
                        ),
                      );
                      await TelegramService.sendFeedback(msg);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context).t('thank_you_rating'),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${AppLocalizations.of(context).t('failed_send_rating')} ${e.toString()}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context).t('send')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Show feedback dialog where user can enter message and optionally contact info
  void _showFeedbackDialog() async {
    final messageController = TextEditingController();
    final contactController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeProvider.getCardColor(),
          title: Text(
            AppLocalizations.of(context).t('send_feedback'),
            style: TextStyle(color: ThemeProvider.getTextColor()),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).t('describing_issue'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(
                    context,
                  ).t('contact_email_telegram'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).t('cancel')),
            ),
            TextButton(
              onPressed: () async {
                final msg = messageController.text.trim();
                final contact = contactController.text.trim();
                if (msg.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).t('enter_feedback'),
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final fullMessage =
                    'Feedback:\n$msg\n${contact.isNotEmpty ? '\nContact: $contact' : ''}';

                // Try sending via TelegramService
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).t('sending_feedback'),
                      ),
                    ),
                  );
                  await TelegramService.sendFeedback(fullMessage);
                  Navigator.pop(context); // close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).t('feedback_sent'),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  // If credentials missing, prompt to configure
                  final err = e.toString();
                  if (err.contains('not configured')) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          backgroundColor: ThemeProvider.getCardColor(),
                          title: Text(
                            AppLocalizations.of(
                              context,
                            ).t('configure_telegram'),
                            style: TextStyle(
                              color: ThemeProvider.getTextColor(),
                            ),
                          ),
                          content: Text(
                            AppLocalizations.of(
                              context,
                            ).t('telegram_not_configured'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                AppLocalizations.of(context).t('cancel'),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${AppLocalizations.of(context).t('failed_send_feedback')} ${e.toString()}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context).t('send')),
            ),
          ],
        );
      },
    );
  }
}
