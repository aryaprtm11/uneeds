import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uneeds/utils/color.dart';
import 'package:uneeds/views/settings_page.dart';
import 'package:uneeds/views/schedule_page.dart';
import 'package:uneeds/views/note_page.dart';
import 'package:uneeds/views/target_page.dart';
import 'package:uneeds/views/notification_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

// Import halaman untuk tambah data
import 'package:uneeds/views/add_schedule.dart';
import 'package:uneeds/views/tambah_catatan.dart';
import 'package:uneeds/views/add_target.dart';

// Database Service dan Models
import 'package:uneeds/services/database_service.dart';
import 'package:uneeds/models/jadwal.dart';
import 'package:uneeds/models/target.dart';
import 'package:uneeds/services/local_notification_service.dart';

class HomePage extends StatefulWidget {
  final User? user;
  const HomePage({this.user, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  String firstName = "";
  final DatabaseService _databaseService = DatabaseService.instance;
  
  List<Jadwal> _todaySchedules = [];
  List<Jadwal> _tomorrowSchedules = [];
  List<TargetPersonal> _upcomingTargets = [];
  bool _isScheduleToday = true;
  bool _isLoading = true;
  int _unreadNotificationCount = 0;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    user = widget.user ?? FirebaseAuth.instance.currentUser;

    // Mendapatkan nama depan user
    if (user != null && user!.displayName != null) {
      firstName = _getFirstName(user!.displayName!);
    } else {
      firstName = "User";
    }

    _loadHomeData();
    _initializeNotifications();
    _loadNotificationCount();
    _loadProfileImage(); // Load profile image
  }

  Future<void> _loadHomeData() async {
    try {
      final schedules = await _databaseService.getJadwal();
      final targets = await _databaseService.getAllTargets();
      
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final todayString = _getDayString(today.weekday);
      final tomorrowString = _getDayString(tomorrow.weekday);

      setState(() {
        _todaySchedules = schedules.where((s) => s.hari == todayString).toList();
        _tomorrowSchedules = schedules.where((s) => s.hari == tomorrowString).toList();
        
        // Filter target mendatang (belum selesai)
        _upcomingTargets = targets.take(3).toList(); // Ambil 3 target pertama
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading home data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNotificationCount() async {
    try {
      final unreadNotifications = await _databaseService.getUnreadNotifications();
      setState(() {
        _unreadNotificationCount = unreadNotifications.length;
      });
    } catch (e) {
      print('Error loading notification count: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    // Initialize local notification service
    await LocalNotificationService().initialize();
  }

  String _getDayString(int weekday) {
    switch (weekday) {
      case 1: return 'Senin';
      case 2: return 'Selasa';
      case 3: return 'Rabu';
      case 4: return 'Kamis';
      case 5: return 'Jumat';
      case 6: return 'Sabtu';
      case 7: return 'Minggu';
      default: return 'Senin';
    }
  }

  // Fungsi untuk mendapatkan nama depan dari nama lengkap
  String _getFirstName(String fullName) {
    List<String> nameParts = fullName.trim().split(" ");
    return nameParts[0];
  }

  // Method untuk menampilkan popup bubble
  void _showAddOptionsPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Text(
                  'Tambah Data Baru',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F4D70),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Option 1: Tambah Jadwal
                _buildPopupOption(
                  icon: Icons.calendar_today_rounded,
                  title: 'Tambah Jadwal',
                  subtitle: 'Buat jadwal kuliah baru',
                  color: primaryBlueColor,
                  onTap: () {
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
                
                // Option 2: Tambah Catatan
                _buildPopupOption(
                  icon: Icons.note_add_rounded,
                  title: 'Tambah Catatan',
                  subtitle: 'Tulis catatan kuliah baru',
                  color: Color(0xFF2E7D32),
                  onTap: () {
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
                
                // Option 3: Tambah Target
                _buildPopupOption(
                  icon: Icons.flag_rounded,
                  title: 'Tambah Target',
                  subtitle: 'Tetapkan target baru',
                  color: Color(0xFFE65100),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTargetPage(),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Close button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget untuk setiap opsi dalam popup
  Widget _buildPopupOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F4D70),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(Jadwal jadwal) {
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
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: primaryBlueColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jadwal.matkul,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F4D70),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  jadwal.dosen,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      jadwal.ruangan,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryBlueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${jadwal.waktuMulai} - ${jadwal.waktuSelesai}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: primaryBlueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCard(TargetPersonal target) {
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.flag_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.namaTarget,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F4D70),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.red[400]),
                    const SizedBox(width: 4),
                    Text(
                      'Deadline: ${target.tanggalTarget}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              target.jenisTarget,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image');
    });
  }

  // Fungsi untuk mendapatkan greeting berdasarkan waktu
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Selamat Pagi";
    } else if (hour < 15) {
      return "Selamat Siang";
    } else if (hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }

  // Fungsi untuk mendapatkan tanggal dalam format Indonesia
  String _getCurrentDate() {
    final now = DateTime.now();
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${days[now.weekday % 7]}, ${now.day} ${months[now.month]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFE6F2FD), // Latar belakang biru muda
      body: Column(
        children: [
          // Header Card dengan design yang lebih menarik
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.95),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Row dengan Profile dan Notifications
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile Section
                    Expanded(
                      child: Row(
                        children: [
                          // Profile Image
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryBlueColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlueColor.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _profileImagePath != null && File(_profileImagePath!).existsSync()
                                  ? Image.file(
                                      File(_profileImagePath!),
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: primaryBlueColor.withOpacity(0.1),
                                      child: Icon(
                                        Icons.person,
                                        color: primaryBlueColor,
                                        size: 30,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          
                          // Greeting dan Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getTimeBasedGreeting(),
                                  style: TextStyle(
                                    color: Color(0xFF4A6D8C),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  firstName,
                                  style: TextStyle(
                                    color: Color(0xFF1F4D70),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Online',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Action Buttons
                    Row(
                      children: [
                        // Notification Button
                        InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationPage(),
                              ),
                            );
                            if (result != null) {
                              _loadNotificationCount();
                            }
                          },
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: primaryBlueColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryBlueColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: primaryBlueColor,
                                    size: 22,
                                  ),
                                ),
                                if (_unreadNotificationCount > 0)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Text(
                                        _unreadNotificationCount > 99 
                                          ? '99+' 
                                          : _unreadNotificationCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // Settings Button
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingPage(),
                              ),
                            ).then((_) {
                              // Reload profile image setelah kembali dari settings
                              _loadProfileImage();
                            });
                          },
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: primaryBlueColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryBlueColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.settings_outlined,
                              color: primaryBlueColor,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Date dan Quick Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryBlueColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: primaryBlueColor.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: primaryBlueColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getCurrentDate(),
                            style: TextStyle(
                              color: primaryBlueColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Quick Stats
                    Row(
                      children: [
                        _buildQuickStat(
                          icon: Icons.schedule,
                          count: _todaySchedules.length,
                          label: 'Jadwal',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _buildQuickStat(
                          icon: Icons.flag,
                          count: _upcomingTargets.length,
                          label: 'Target',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content Area (Jadwal dan Target)
          Expanded(
            child: _isLoading 
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1F4D70),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Jadwal Mendatang Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Jadwal Mendatang',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F4D70),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SchedulePage(),
                                ),
                              );
                            },
                            child: Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryBlueColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Filter Toggle
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
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
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _isScheduleToday = true;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _isScheduleToday ? primaryBlueColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Hari Ini',
                                      style: TextStyle(
                                        color: _isScheduleToday ? Colors.white : Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _isScheduleToday = false;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !_isScheduleToday ? primaryBlueColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Besok',
                                      style: TextStyle(
                                        color: !_isScheduleToday ? Colors.white : Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Schedule List
                      if (_isScheduleToday) ...[
                        if (_todaySchedules.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Tidak ada jadwal hari ini',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        else
                          ..._todaySchedules.map((jadwal) => _buildScheduleCard(jadwal)),
                      ] else ...[
                        if (_tomorrowSchedules.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Tidak ada jadwal besok',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        else
                          ..._tomorrowSchedules.map((jadwal) => _buildScheduleCard(jadwal)),
                      ],

                      const SizedBox(height: 32),

                      // Target Mendatang Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Target Mendatang',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F4D70),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TargetPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryBlueColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Target List
                      if (_upcomingTargets.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Belum ada target',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._upcomingTargets.map((target) => _buildTargetCard(target)),

                      const SizedBox(height: 100), // Extra space for navbar
                    ],
                  ),
                ),
          ),

          // Navbar dan tombol plus
          Padding(
            padding: const EdgeInsets.only(bottom: 55),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container navbar utama
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
                      // Home button (active)
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: primaryBlueColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      // Calendar button
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      SchedulePage(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: primaryBlueColor,
                          size: 30,
                        ),
                      ),

                      // List button
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      NotePage(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child: Icon(
                          Icons.view_list_rounded,
                          color: primaryBlueColor,
                          size: 30,
                        ),
                      ),

                      // Molecule/Api button
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      TargetPage(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child: Icon(
                          Icons.api_rounded,
                          color: primaryBlueColor,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),

                // Plus button (diluar navbar)
                InkWell(
                  onTap: _showAddOptionsPopup,
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.only(left: 10),
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
                    child: Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
