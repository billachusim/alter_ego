import 'package:alter_ego/services/app_settings_service.dart';
import 'package:alter_ego/services/notification_service.dart';
import 'package:alter_ego/services/share_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = AppSettingsService();
  bool _notificationsEnabled = true;
  int _notificationHour = 20;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _settings.notificationsEnabled();
    final hour = await _settings.notificationHour();
    setState(() {
      _notificationsEnabled = enabled;
      _notificationHour = hour;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermissions();
      if (!granted) return;
    }
    await _settings.setNotificationsEnabled(value);
    setState(() => _notificationsEnabled = value);
    await NotificationService.instance.syncNotifications();
  }

  Future<void> _changeTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _notificationHour, minute: 0),
    );
    if (time != null) {
      await _settings.setNotificationHour(time.hour);
      setState(() => _notificationHour = time.hour);
      await NotificationService.instance.syncNotifications();
    }
  }

  Future<void> _shareApp() async {
    await ShareService.shareText(
      context,
      'Check out Alter Ego - a private way to map your internal voices.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Daily Reminders'),
            subtitle: const Text('Get notified for your daily council check-in.'),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          if (_notificationsEnabled)
            ListTile(
              title: const Text('Reminder Time'),
              subtitle: Text('Currently set to $_notificationHour:00'),
              trailing: const Icon(Icons.access_time),
              onTap: _changeTime,
            ),
          const Divider(),
          ListTile(
            title: const Text('Share with Friends'),
            leading: const Icon(Icons.share),
            onTap: _shareApp,
          ),
          const Divider(),
          ListTile(
            title: const Text('Privacy Policy'),
            onTap: () => launchUrl(Uri.parse('https://sites.google.com/view/claire-diary/alter-ego-app-terms-of-use-and-privacy-policy')),
          ),
          ListTile(
            title: const Text('Terms of Use'),
            onTap: () => launchUrl(Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/')),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Alter Ego v1.5.0',
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
