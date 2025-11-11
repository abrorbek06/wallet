import 'package:app/screens/settings/dialogs/about_dialog.dart';
import 'package:app/screens/settings/widgets/category_section.dart';
import 'package:app/screens/settings/widgets/info_section.dart';
import 'package:app/screens/settings/widgets/theme_section.dart';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../models/themes.dart';
import '../../functions/category_managment.dart';
import '../../services/telegram_service.dart';

class SettingsScreen extends StatefulWidget {
  final String currentTheme;
  final Function(String) onThemeChanged;
  final Function(Category) onAddCategory;
  final Function(String, bool) onRemoveCategory;

  const SettingsScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.onAddCategory,
    required this.onRemoveCategory,
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
          'Settings',
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
          // Daily Limit Setting
          // ListTile(
          //   contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          //   title: Text(
          //     'Daily Spending Limit',
          //     style: TextStyle(
          //       color: ThemeProvider.getTextColor(),
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          //   subtitle: Text(
          //     _dailyLimit != null
          //         ? '\$${_dailyLimit!.toStringAsFixed(2)}'
          //         : 'Not set',
          //     style: TextStyle(color: Colors.grey[500]),
          //   ),
          //   trailing: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       TextButton(
          //         onPressed: () async {
          //           final result = await showDialog<double?>(
          //             context: context,
          //             builder: (context) {
          //               final controller = TextEditingController(
          //                 text: _dailyLimit?.toStringAsFixed(2) ?? '',
          //               );
          //               return AlertDialog(
          //                 backgroundColor: ThemeProvider.getCardColor(),
          //                 title: Text(
          //                   'Set Daily Limit',
          //                   style: TextStyle(
          //                     color: ThemeProvider.getTextColor(),
          //                   ),
          //                 ),
          //                 content: TextField(
          //                   controller: controller,
          //                   keyboardType: TextInputType.numberWithOptions(
          //                     decimal: true,
          //                   ),
          //                   decoration: InputDecoration(
          //                     hintText: 'Enter daily spending limit',
          //                   ),
          //                 ),
          //                 actions: [
          //                   TextButton(
          //                     onPressed: () => Navigator.pop(context, null),
          //                     child: Text('Cancel'),
          //                   ),
          //                   TextButton(
          //                     onPressed: () {
          //                       final text = controller.text.trim();
          //                       if (text.isEmpty) return Navigator.pop(context, null);
          //                       final val = double.tryParse(text);
          //                       Navigator.pop(context, val);
          //                     },
          //                     child: Text('Save'),
          //                   ),
          //                 ],
          //               );
          //             },
          //           );
          //           if (result != null) {
          //             await saveDailyLimit(result);
          //             setState(() => _dailyLimit = result);
          //           }
          //         },
          //         child: Text('Set'),
          //       ),
          //       if (_dailyLimit != null) SizedBox(width: 8),
          //       if (_dailyLimit != null)
          //         TextButton(
          //           onPressed: () async {
          //             await saveDailyLimit(null);
          //             setState(() => _dailyLimit = null);
          //           },
          //           child: Text('Clear', style: TextStyle(color: Colors.red)),
          //         ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 24),
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
          InfoSection(onRateApp: _rateApp, onHelpPressed: _showAboutDialog),
          const SizedBox(height: 24),
          // Feedback
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.feedback,
              color: ThemeProvider.getPrimaryColor(),
            ),
            title: Text(
              'Send Feedback',
              style: TextStyle(
                color: ThemeProvider.getTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Report bugs or suggestions',
              style: TextStyle(color: Colors.grey[500]),
            ),
            onTap: _showFeedbackDialog,
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.telegram, color: Colors.blue),
            title: Text(
              'Configure Telegram',
              style: TextStyle(
                color: ThemeProvider.getTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Set bot token and chat id to receive feedback',
              style: TextStyle(color: Colors.grey[500]),
            ),
            onTap: _configureTelegramDialog,
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutAppDialog(context);
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rating functionality coming soon!'),
        backgroundColor: Colors.blue,
      ),
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
            'Send Feedback',
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
                      content: Text('Please enter your feedback'),
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
                    SnackBar(content: Text('Sending feedback...')),
                  );
                  await TelegramService.sendFeedback(fullMessage);
                  Navigator.pop(context); // close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Feedback sent — thank you!'),
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
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _configureTelegramDialog();
                              },
                              child: const Text('Configure'),
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

  /// Dialog to configure Telegram bot token and chat id
  void _configureTelegramDialog() async {
    final creds = await TelegramService.getCredentials();
    final tokenController = TextEditingController(text: creds['token'] ?? '');
    final chatController = TextEditingController(text: creds['chatId'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeProvider.getCardColor(),
          title: Text(
            'Configure Telegram',
            style: TextStyle(color: ThemeProvider.getTextColor()),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tokenController,
                decoration: InputDecoration(
                  hintText: 'Bot token (from @BotFather)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: chatController,
                decoration: InputDecoration(hintText: 'Chat id (or @channel)'),
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
                final token = tokenController.text.trim();
                final chat = chatController.text.trim();
                if (token.isEmpty || chat.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Both token and chat id are required'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Try a test send before saving
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Testing Telegram credentials...')),
                  );
                  await TelegramService.sendFeedback(
                    'Test message from app',
                    botToken: token,
                    chatId: chat,
                  );
                  // If success, save
                  await TelegramService.saveCredentials(token, chat);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Telegram configured and test message sent',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Test failed: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save & Test'),
            ),
          ],
        );
      },
    );
  }
}
