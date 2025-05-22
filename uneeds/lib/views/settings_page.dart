import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uneeds/views/profile_edit.dart';

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String imagePath = '';
  String name = '';
  String email = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      imagePath = prefs.getString('profile_image') ?? '';
      name = prefs.getString('name') ?? 'uneeds';
      email = prefs.getString('email') ?? 'uneedsapp@gmail.com';
      phone = prefs.getString('phone') ?? '08123456789';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                'Pengaturan',
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
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2B4865),
                      shape: BoxShape.circle,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Foto profile
            Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  // backgroundImage: AssetImage('assets/gambar/profile.png'),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(email),
                Text(phone),
                const SizedBox(height: 6),
              ],
            ),
            const SizedBox(height: 60),
            _MenuItem(
              icon: Icons.person_outline,
              label: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileEdit()),
                ).then(
                  (_) => loadProfile(),
                ); // Refresh setelah kembali dari edit
              },
            ),
            _MenuItem(
              icon: Icons.notifications_none,
              label: 'Notifikasi',
              onTap: () {
                // untuk notif
              },
            ),
            _MenuItem(
              icon: Icons.description_outlined,
              label: 'Kebijakan pengguna',
              onTap: () {
                // untuk kebijakan pengguna
              },
            ),
            _MenuItem(
              icon: Icons.assignment_outlined,
              label: 'Kebijakan privasi',
              onTap: () {
                // untuk kebijakan privasi
              },
            ),
          ],
        ),
      ),
    );
  }
}
