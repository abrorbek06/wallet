import 'package:flutter/material.dart';
import '../../../models/themes.dart';
import '../../../l10n/app_localizations.dart';

class InfoSection extends StatelessWidget {
  final VoidCallback onHelpPressed;
  final VoidCallback onRateApp;

  const InfoSection({
    super.key,
    required this.onHelpPressed,
    required this.onRateApp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 24),
              SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).t('settings'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            AppLocalizations.of(context).t('version'),
            AppLocalizations.of(context).t('app_version_value'),
          ),
          _buildInfoRow(
            AppLocalizations.of(context).t('developer'),
            AppLocalizations.of(context).t('developer_name_value'),
          ),
          _buildInfoRow(
            AppLocalizations.of(context).t('last_updated'),
            AppLocalizations.of(context).t('last_updated_value'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onHelpPressed,
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: Text(
                    AppLocalizations.of(context).t('send_feedback'),
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRateApp,
                  icon: const Icon(Icons.star_outline, size: 18),
                  label: Text(AppLocalizations.of(context).t('rate_app')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
