import 'package:flutter/material.dart';
import 'package:uneeds/models/jadwal.dart';
import 'package:uneeds/services/database_service.dart';
import 'package:uneeds/utils/color.dart';
import 'package:uneeds/views/home_page.dart';
import 'package:uneeds/views/note_page.dart';
import 'package:uneeds/views/target_page.dart';
import 'package:uneeds/views/add_schedule.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Jadwal\nKuliah',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2B4865),
                              height: 1.1,
                            ),
                          ),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B4865),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const AddSchedulePage(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                              label: const Text(
                                'Tambah Jadwal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B4865),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _dayButton('S', true),
                            _dayButton('S', false),
                            _dayButton('R', false),
                            _dayButton('K', false),
                            _dayButton('J', false),
                            _dayButton('S', false),
                            _dayButton('M', false),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B4865),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: FutureBuilder<List<Jadwal>?>(
                          future: _databaseService.getJadwal(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: \${snapshot.error}'),
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data!.isNotEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Senin',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...snapshot.data!.map(
                                    (jadwal) => _scheduleTimeRow(
                                      jadwal.waktuMulai,
                                      _scheduleCard(
                                        jadwal.matkul,
                                        jadwal.dosen,
                                        "${jadwal.waktuMulai} - ${jadwal.waktuSelesai}",
                                        jadwal.ruangan,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return const Center(
                                child: Text(
                                  'Tidak ada jadwal.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.65,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _navIcon(context, Icons.home_rounded, HomePage(), false),
                      _navIcon(
                        context,
                        Icons.calendar_today_rounded,
                        SchedulePage(),
                        true,
                      ),
                      _navIcon(
                        context,
                        Icons.view_list_rounded,
                        NotePage(),
                        false,
                      ),
                      _navIcon(context, Icons.api_rounded, TargetPage(), false),
                    ],
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: primaryBlueColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
          const SizedBox(height: 55),
        ],
      ),
    );
  }

  Widget _dayButton(String day, bool isSelected) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: isSelected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      border: !isSelected ? Border.all(color: Colors.white, width: 1) : null,
    ),
    child: Center(
      child: Text(
        day,
        style: TextStyle(
          color: isSelected ? const Color(0xFF2B4865) : Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  Widget _scheduleTimeRow(String time, Widget card) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.5),
              margin: const EdgeInsets.only(left: 12),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Padding(padding: const EdgeInsets.only(left: 85), child: card),
    ],
  );

  Widget _scheduleCard(
    String subject,
    String lecturer,
    String duration,
    String room, {
    bool isLast = false,
  }) => Container(
    margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF4A7B97).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.video_camera_front_rounded,
            color: Color(0xFF4A7B97),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2B4865),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Dosen: $lecturer",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                duration,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                room,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF2B4865),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
        ),
      ],
    ),
  );

  Widget _navIcon(
    BuildContext context,
    IconData icon,
    Widget page,
    bool isActive,
  ) {
    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => page,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? primaryBlueColor : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : primaryBlueColor,
          size: 30,
        ),
      ),
    );
  }
}
