// Data Management section in SettingsScreen
/*
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: ThemeProvider.getCardColor(),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            Icons.storage,
            color: Colors.blue,
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            'Data Management',
            style: TextStyle(
              color: ThemeProvider.getTextColor(),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      SizedBox(height: 16),

      _buildDataOption(
        'Export Data',
        'Export your transactions to CSV',
        Icons.file_download,
        Colors.green,
            () => _exportData(),
      ),
      SizedBox(height: 12),
      _buildDataOption(
        'Import Data',
        'Import transactions from CSV',
        Icons.file_upload,
        Colors.blue,
            () => _importData(),
      ),
      SizedBox(height: 12),
      _buildDataOption(
        'Backup Data',
        'Create a backup of your data',
        Icons.backup,
        Colors.orange,
            () => _backupData(),
      ),
      SizedBox(height: 12),
      _buildDataOption(
        'Clear All Data',
        'Delete all transactions and reset app',
        Icons.delete_forever,
        Colors.red,
            () => _showClearDataDialog(),
      ),
    ],
  ),
),

SizedBox(height: 24),
*/

// Data Option builder widget
/*
Widget _buildDataOption(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ThemeProvider.getTextColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[400],
            size: 16,
          ),
        ],
      ),
    ),
  );
}
*/

// Notification options section
/*
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: ThemeProvider.getCardColor(),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            Icons.notifications,
            color: Colors.purple,
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            'Notifications',
            style: TextStyle(
              color: ThemeProvider.getTextColor(),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      SizedBox(height: 16),

      _buildNotificationOption(
        'Budget Alerts',
        'Get notified when you exceed budget limits',
        true,
            (value) => {},
      ),
      SizedBox(height: 12),
      _buildNotificationOption(
        'Daily Reminders',
        'Remind me to log daily expenses',
        false,
            (value) => {},
      ),
      SizedBox(height: 12),
      _buildNotificationOption(
        'Weekly Reports',
        'Send weekly spending summary',
        true,
            (value) => {},
      ),
    ],
  ),
),
*/

// Notification option builder widget
/*
Widget _buildNotificationOption(String title, String subtitle, bool value, Function(bool) onChanged) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.purple.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.purple.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: ThemeProvider.getTextColor(),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.purple,
        ),
      ],
    ),
  );
}
*/

// Backup Data function
/*
void _backupData() {
  // TODO: Implement data backup functionality
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Backup functionality coming soon!'),
      backgroundColor: Colors.orange,
    ),
  );
}
*/

// Clear All Data dialog function
/*
void _showClearDataDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: ThemeProvider.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Clear All Data',
        style: TextStyle(
          color: ThemeProvider.getTextColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'This will permanently delete all your transactions, categories, and settings. This action cannot be undone.',
            style: TextStyle(
              color: ThemeProvider.getTextColor(),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement clear all data functionality
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Clear data functionality coming soon!'),
                backgroundColor: Colors.red,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Clear All',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
*/
