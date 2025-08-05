import 'package:app/models/themes.dart';
import 'package:flutter/material.dart';

void showAboutAppDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: ThemeProvider.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'About Finance Pro',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Finance Pro is a comprehensive expense tracking app designed to help you manage your finances effectively.',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 16),
          Text('Features:', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(
            '• Track income and expenses\n• Categorize transactions\n• Visual charts and statistics\n• Multiple themes\n• Card management\n• Budget tracking',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
