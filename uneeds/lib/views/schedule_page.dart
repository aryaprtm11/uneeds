import 'package:flutter/material.dart';

// Utils
import 'package:uneeds/utils/color.dart';

// Views
import 'package:uneeds/views/home_page.dart';
import 'package:uneeds/views/note_page.dart';
import 'package:uneeds/views/target_page.dart';
import 'package:uneeds/views/add_schedule.dart';
import 'package:uneeds/views/edit_schedule.dart';
import 'package:uneeds/views/add_target.dart';
import 'package:uneeds/views/tambah_catatan.dart';

// Database Service
import 'package:uneeds/services/database_service.dart';

// Database Models
import 'package:uneeds/models/jadwal.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService.instance;
  String selectedDay = 'Senin'; // Default hari yang dipilih
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Map untuk konversi singkatan hari ke nama lengkap
  final Map<String, String> dayAbbreviations = {
    'S': 'Senin',
    'S': 'Selasa',
    'R': 'Rabu',
    'K': 'Kamis',
    'J': 'Jumat',
    'S': 'Sabtu',
    'M': 'Minggu',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Mulai animasi
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengubah hari yang dipilih
  void _onDaySelected(String abbreviation) {
    setState(() {
      selectedDay = dayAbbreviations[abbreviation] ?? 'Senin';
    });
  }

  void _showAddOptionsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tambah Data Baru',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B4865),
                  ),
                ),
                const SizedBox(height: 20),
                _buildPopupOption(
                  'Tambah Jadwal',
                  Icons.calendar_today_rounded,
                  const Color(0xFF4A90E2),
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddSchedulePage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildPopupOption(
                  'Tambah Catatan',
                  Icons.note_add_rounded,
                  const Color(0xFF50C878),
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TambahCatatanPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildPopupOption(
                  'Tambah Target',
                  Icons.flag_rounded,
                  const Color(0xFFFF6B6B),
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTargetPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupOption(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FD),
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
                                    builder: (context) => const AddSchedulePage(),
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
                            _buildDayFilter('S', 'Senin'),
                            _buildDayFilter('S', 'Selasa'),
                            _buildDayFilter('R', 'Rabu'),
                            _buildDayFilter('K', 'Kamis'),
                            _buildDayFilter('J', 'Jumat'),
                            _buildDayFilter('S', 'Sabtu'),
                            _buildDayFilter('M', 'Minggu'),
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
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data!.isNotEmpty) {
                              // Filter jadwal berdasarkan hari yang dipilih
                              final filteredJadwal =
                                  snapshot.data!
                                      .where(
                                        (jadwal) => jadwal.hari == selectedDay,
                                      )
                                      .toList();

                              if (filteredJadwal.isEmpty) {
                                return Center(
                                  child: Text(
                                    'Tidak ada jadwal untuk hari $selectedDay',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedDay,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...filteredJadwal.map(
                                    (jadwal) => _scheduleTimeRow(
                                      jadwal.waktuMulai,
                                      _scheduleCard(
                                        jadwal.matkul,
                                        jadwal.dosen,
                                        "${jadwal.waktuMulai} - ${jadwal.waktuSelesai}",
                                        jadwal.ruangan,
                                        jadwal: jadwal,
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
          Padding(
            padding: const EdgeInsets.only(bottom: 55),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.65,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2B4865).withOpacity(0.15),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
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
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlueColor.withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: _showAddOptionsPopup,
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayFilter(String abbreviation, String fullDay) {
    bool isSelected = selectedDay == fullDay;
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDay = fullDay;
            // Reset dan jalankan animasi lagi
            _animationController.reset();
            _animationController.forward();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border:
                !isSelected ? Border.all(color: Colors.white, width: 1) : null,
          ),
          child: Center(
            child: Text(
              abbreviation,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2B4865) : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

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
    Jadwal? jadwal,
  }) => SlideTransition(
    position: _slideAnimation,
    child: ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
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
              InkWell(
                onTap:
                    jadwal != null
                        ? () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => EditSchedulePage(jadwal: jadwal),
                            ),
                          );
                          if (result == true) {
                            setState(() {
                              // Reset dan jalankan animasi lagi
                              _animationController.reset();
                              _animationController.forward();
                            });
                          }
                        }
                        : null,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B4865),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
