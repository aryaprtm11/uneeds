import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneeds/utils/color.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _scheduleNotification = true;
  bool _deadlineNotification = true;
  bool _generalNotification = true;
  bool _targetReminderNotification = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  
  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _scheduleNotification = prefs.getBool('schedule_notification') ?? true;
      _deadlineNotification = prefs.getBool('deadline_notification') ?? true;
      _generalNotification = prefs.getBool('general_notification') ?? true;
      _targetReminderNotification = prefs.getBool('target_reminder_notification') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    });
  }

  Future<void> _saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('schedule_notification', _scheduleNotification);
    await prefs.setBool('deadline_notification', _deadlineNotification);
    await prefs.setBool('general_notification', _generalNotification);
    await prefs.setBool('target_reminder_notification', _targetReminderNotification);
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan notifikasi berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryBlueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: primaryBlueColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F4D70),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryBlueColor,
            activeTrackColor: primaryBlueColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                'Pengaturan Notifikasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B4865),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B4865),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2B4865).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: primaryBlueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryBlueColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: primaryBlueColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Atur jenis notifikasi yang ingin Anda terima untuk membantu mengelola jadwal dan target Anda. Notifikasi akan otomatis terjadwal berdasarkan deadline dan jadwal kuliah.',
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryBlueColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Notifikasi Konten
            const Text(
              'Notifikasi Konten',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F4D70),
              ),
            ),
            const SizedBox(height: 16),

            _buildNotificationTile(
              title: 'Notifikasi Jadwal',
              subtitle: 'Pengingat untuk jadwal kuliah yang akan dimulai',
              value: _scheduleNotification,
              onChanged: (value) {
                setState(() {
                  _scheduleNotification = value;
                });
              },
              icon: Icons.calendar_today,
            ),

            _buildNotificationTile(
              title: 'Notifikasi Deadline',
              subtitle: 'Pengingat untuk tugas dan deadline yang mendekat',
              value: _deadlineNotification,
              onChanged: (value) {
                setState(() {
                  _deadlineNotification = value;
                });
              },
              icon: Icons.access_time,
            ),

            _buildNotificationTile(
              title: 'Pengingat Target',
              subtitle: 'Notifikasi untuk target personal yang perlu dicapai',
              value: _targetReminderNotification,
              onChanged: (value) {
                setState(() {
                  _targetReminderNotification = value;
                });
              },
              icon: Icons.flag,
            ),

            _buildNotificationTile(
              title: 'Notifikasi Umum',
              subtitle: 'Notifikasi update aplikasi dan informasi penting',
              value: _generalNotification,
              onChanged: (value) {
                setState(() {
                  _generalNotification = value;
                });
              },
              icon: Icons.notifications,
            ),

            const SizedBox(height: 32),

            // Pengaturan Media
            const Text(
              'Pengaturan Media',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F4D70),
              ),
            ),
            const SizedBox(height: 16),

            _buildNotificationTile(
              title: 'Suara Notifikasi',
              subtitle: 'Mainkan suara saat menerima notifikasi',
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
              icon: Icons.volume_up,
            ),

            _buildNotificationTile(
              title: 'Getaran',
              subtitle: 'Aktifkan getaran saat menerima notifikasi',
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              },
              icon: Icons.vibration,
            ),

            const SizedBox(height: 32),

            // Tombol Simpan
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlueColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveNotificationSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlueColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Simpan Pengaturan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} 