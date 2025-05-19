import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'PROFILE',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile picture and name
            Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/gambar/profile.png'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'uneeds',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('uneedsapp@gmail.com'),
                const Text('08123456789'),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Aktivitas
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _ActivityItem(title: 'Materi tersimpan', value: '3'),
                  _ActivityItem(title: 'Jumlah Catatan', value: '7'),
                  _ActivityItem(title: 'Target Selesai', value: '4'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Menu items
            const _MenuItem(icon: Icons.person_outline, label: 'Profil'),
            const _MenuItem(
              icon: Icons.notifications_none,
              label: 'Notifikasi',
            ),
            const _MenuItem(
              icon: Icons.description_outlined,
              label: 'Kebijakan pengguna',
            ),
            const _MenuItem(
              icon: Icons.assignment_outlined,
              label: 'Kebijakan privasi',
            ),
            const _MenuItem(icon: Icons.lock_outline, label: 'Ubah passsword'),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String value;

  const _ActivityItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
