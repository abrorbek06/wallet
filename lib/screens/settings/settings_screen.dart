import 'package:app/screens/settings/widgets/category_section.dart';
import 'package:app/screens/settings/widgets/info_section.dart';
import 'package:app/screens/settings/widgets/theme_section.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../models/themes.dart';
import '../../functions/category_managment.dart';
import '../../services/telegram_service.dart';

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
  @override
  void initState() {
    super.initState();
    CategoryManager.loadSavedCategories();
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
        return AlertDialog(
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
                    decoration: InputDecoration(hintText: 'Optional comment'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
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
                  child: const Text('Send'),
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
                  hintText: 'Describe the issue or suggestion',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  hintText: 'Optional: contact (email/telegram)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
                            'Telegram not configured',
                            style: TextStyle(
                              color: ThemeProvider.getTextColor(),
                            ),
                          ),
                          content: Text(
                            'Please configure your Telegram bot token and chat id to receive feedback.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
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
                          'Failed to send feedback: ${e.toString()}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
}
