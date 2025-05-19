import 'package:flutter/material.dart';
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

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

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
          'PROFIL',
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
                // TextButton.icon(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const ProfileEdit(),
                //       ),
                //     );
                //   },
                //   icon: Icon(Icons.edit, color: Colors.blue),
                //   label: const Text(
                //     'Edit Profile',
                //     style: TextStyle(color: Colors.blue),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 20),

            // Aktivitas
            // Container(
            //   decoration: BoxDecoration(
            //     color: Colors.grey[200],
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   padding: const EdgeInsets.symmetric(vertical: 12),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: const [
            //       _ActivityItem(title: 'Materi tersimpan', value: '3'),
            //       _ActivityItem(title: 'Jumlah Catatan', value: '7'),
            //       _ActivityItem(title: 'Target Selesai', value: '4'),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 20),
            // Menu items
            const SizedBox(height: 20),
            _MenuItem(
              icon: Icons.person_outline,
              label: 'Profil',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileEdit()),
                );
              },
            ),
            _MenuItem(
              icon: Icons.notifications_none,
              label: 'Notifikasi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileEdit()),
                );
              },
            ),
            _MenuItem(
              icon: Icons.description_outlined,
              label: 'Kebijakan pengguna',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileEdit()),
                );
              },
            ),
            _MenuItem(
              icon: Icons.assignment_outlined,
              label: 'Kebijakan privasi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileEdit()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
