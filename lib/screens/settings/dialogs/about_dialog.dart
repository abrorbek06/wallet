import 'package:app/models/themes.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

void showAboutAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          backgroundColor: ThemeProvider.getCardColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            AppLocalizations.of(context).t('about_title'),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).t('about_description'),
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).t('features_header'),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).t('features_list'),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).t('close')),
            ),
          ],
        ),
  );
}
