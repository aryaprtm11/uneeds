import 'package:flutter/material.dart';
import '../views/add_schedule.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jadwal Kuliah',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddSchedulePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [_buildDayBar(), Expanded(child: _buildScheduleList())],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDayBar() {
    final days = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: days.map((day) => _buildDayItem(day)).toList(),
      ),
    );
  }

  Widget _buildDayItem(String day) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          day,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3, // Contoh data
      itemBuilder: (context, index) {
        return _buildScheduleCard();
      },
    );
  }

  Widget _buildScheduleCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pemrograman Mobile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.person_outline, size: 16),
                SizedBox(width: 8),
                Text('Dr. John Doe'),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.access_time, size: 16),
                SizedBox(width: 8),
                Text('08:00 - 09:40'),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.room_outlined, size: 16),
                SizedBox(width: 8),
                Text('Ruang 301'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: '',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'List'),
        BottomNavigationBarItem(icon: Icon(Icons.api), label: 'API'),
      ],
      currentIndex: 1,
      selectedItemColor: Colors.blue,
    );
  }
}
