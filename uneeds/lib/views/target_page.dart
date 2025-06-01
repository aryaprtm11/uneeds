import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Utils
import 'package:uneeds/utils/color.dart';

// Views
import 'package:uneeds/views/home_page.dart';
import 'package:uneeds/views/note_page.dart';
import 'package:uneeds/views/schedule_page.dart';
import 'package:uneeds/views/add_target.dart';
import 'package:uneeds/views/edit_target.dart';
import 'package:uneeds/views/add_schedule.dart';
import 'package:uneeds/views/tambah_catatan.dart';

// Models
import 'package:uneeds/models/target.dart';

// Database Service
import 'package:uneeds/services/database_service.dart';

class TargetPage extends StatefulWidget {
  const TargetPage({super.key});

  @override
  State<TargetPage> createState() => _TargetPageState();
}

class _TargetPageState extends State<TargetPage>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService.instance;
  late TabController _tabController;
  List<TargetPersonal> _activeTargets = [];
  List<TargetPersonal> _completedTargets = [];
  Map<int, List<CapaianTarget>> _capaianTargets = {};
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Memulai loading data setelah frame pertama selesai dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTargetsOptimized();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fungsi helper untuk memproses capaian dalam batch kecil
  Future<Map<int, List<CapaianTarget>>> _loadCapaianInBatches(
    List<TargetPersonal> targets,
  ) async {
    const batchSize = 3; // Membatasi hanya 3 operasi database bersamaan
    final capaianMap = <int, List<CapaianTarget>>{};
    
    for (int i = 0; i < targets.length; i += batchSize) {
      if (!mounted) return capaianMap;
      
      final batch = targets.skip(i).take(batchSize).toList();
      final futures = batch.map((target) async {
        try {
          final capaian = await _databaseService.getCapaianByTargetId(target.id!);
          return MapEntry(target.id!, capaian);
        } catch (e) {
          print('Error loading capaian for target ${target.id}: $e');
          return MapEntry(target.id!, <CapaianTarget>[]);
        }
      });

      final batchResults = await Future.wait(futures);
      for (final entry in batchResults) {
        capaianMap[entry.key] = entry.value;
      }
      
      // Memberikan jeda kecil untuk UI tetap responsif
      await Future.delayed(const Duration(milliseconds: 10));
    }
    
    return capaianMap;
  }

  Future<void> _loadTargetsOptimized() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Load targets terlebih dahulu
      final targets = await _databaseService.getAllTargets();
      
      if (!mounted) return;

      // Jika tidak ada target, langsung selesai
      if (targets.isEmpty) {
        setState(() {
          _activeTargets = [];
          _completedTargets = [];
          _capaianTargets = {};
          _isLoading = false;
        });
        return;
      }

      // Load capaian dalam batch kecil untuk menghindari overload
      final capaianMap = await _loadCapaianInBatches(targets);
      
      if (!mounted) return;

      // Proses klasifikasi target
      final activeTargets = <TargetPersonal>[];
      final completedTargets = <TargetPersonal>[];

      for (var target in targets) {
        final capaian = capaianMap[target.id] ?? [];
        
        // Target dianggap selesai jika semua capaian completed DAN ada capaian
        bool isCompleted = capaian.isNotEmpty && capaian.every((c) => c.status == 1);
        
        if (isCompleted) {
          completedTargets.add(target);
        } else {
          activeTargets.add(target);
        }
      }

      if (!mounted) return;

      setState(() {
        _activeTargets = activeTargets;
        _completedTargets = completedTargets;
        _capaianTargets = capaianMap;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading targets: $e');
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleCapaian(CapaianTarget capaian) async {
    if (_isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      final newStatus = capaian.status == 0 ? 1 : 0;
      final success = await _databaseService.updateCapaianStatus(
        capaian.id!,
        newStatus,
      );

      if (success && mounted) {
        // Update state lokal tanpa reload database
        final targetId = capaian.idTarget;
        final capaianList = List<CapaianTarget>.from(
          _capaianTargets[targetId] ?? [],
        );
        final index = capaianList.indexWhere((c) => c.id == capaian.id);

        if (index != -1) {
          capaianList[index] = capaian.copyWith(status: newStatus);

          setState(() {
            _capaianTargets[targetId] = capaianList;
          });

          // Check apakah semua capaian sudah selesai
          final allCompleted = capaianList.isNotEmpty && 
                               capaianList.every((c) => c.status == 1);
          
          if (allCompleted) {
            final targetIndex = _activeTargets.indexWhere((t) => t.id == targetId);
            if (targetIndex != -1) {
              final target = _activeTargets[targetIndex];
              setState(() {
                _activeTargets.removeAt(targetIndex);
                _completedTargets.add(target);
              });
            }
          } else {
            // Jika ada capaian yang belum selesai, pastikan target ada di active
            final targetIndex = _completedTargets.indexWhere((t) => t.id == targetId);
            if (targetIndex != -1) {
              final target = _completedTargets[targetIndex];
              setState(() {
                _completedTargets.removeAt(targetIndex);
                _activeTargets.add(target);
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error toggling capaian: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // Reload data dengan optimasi
  Future<void> _refreshData() async {
    await _loadTargetsOptimized();
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
                  () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTargetPage(),
                      ),
                    );
                    if (result == true) {
                      _refreshData();
                    }
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

  Widget _buildTargetCard(TargetPersonal target) {
    final capaianList = _capaianTargets[target.id] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2B4865),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/${_getIconForTargetType(target.jenisTarget)}.png',
                          width: 24,
                          height: 24,
                          color: Colors.white,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 24,
                            );
                          },
                        ),
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
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2B4865),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Deadline: ${target.tanggalTarget}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (capaianList.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: capaianList.length,
                    itemBuilder: (context, index) {
                      final capaian = capaianList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => _toggleCapaian(capaian),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: capaian.status == 1
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFF2B4865),
                                    width: 2,
                                  ),
                                  color: capaian.status == 1
                                      ? const Color(0xFF2E7D32)
                                      : Colors.white,
                                ),
                                child: capaian.status == 1
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                capaian.deskripsiCapaian,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: capaian.status == 1
                                      ? Colors.grey
                                      : Colors.black87,
                                  decoration: capaian.status == 1
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2B4865)),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditTargetPage(target: target),
                  ),
                );
                if (result == true) {
                  _refreshData();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getIconForTargetType(String type) {
    switch (type.toLowerCase()) {
      case 'beasiswa':
        return 'scholarship';
      case 'akademik':
        return 'academic';
      case 'organisasi':
        return 'organization';
      case 'kepanitiaan':
        return 'committee';
      case 'lainnya':
        return 'other';
      default:
        return 'other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FD),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Target\nPersonal',
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
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AddTargetPage(),
                                        ),
                                      );
                                      if (result == true) {
                                        _refreshData();
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    label: const Text(
                                      'Tambah Target',
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
                              decoration: BoxDecoration(
                                color: const Color(0xFF2B4865),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.track_changes_rounded,
                                              color: Color(0xFF8B1919),
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 24),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Target',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                _activeTargets.length.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 80,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check_circle_outline_rounded,
                                              color: Color(0xFF2E7D32),
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 24),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Selesai',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                _completedTargets.length.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
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
                        child: TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Target'),
                            Tab(text: 'Selesai'),
                          ],
                          labelColor: const Color(0xFF2B4865),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: const Color(0xFF2B4865),
                          indicatorWeight: 3,
                        ),
                      ),
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF2B4865),
                                ),
                              )
                            : TabBarView(
                                controller: _tabController,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  // Tab Target Aktif
                                  _activeTargets.isEmpty
                                      ? const Center(
                                          child: Text('Belum ada target aktif'),
                                        )
                                      : ListView.builder(
                                          padding: const EdgeInsets.all(20),
                                          itemCount: _activeTargets.length,
                                          itemBuilder: (context, index) {
                                            return _buildTargetCard(_activeTargets[index]);
                                          },
                                        ),

                                  // Tab Target Selesai
                                  _completedTargets.isEmpty
                                      ? const Center(
                                          child: Text('Belum ada target selesai'),
                                        )
                                      : ListView.builder(
                                          padding: const EdgeInsets.all(20),
                                          itemCount: _completedTargets.length,
                                          itemBuilder: (context, index) {
                                            return _buildTargetCard(_completedTargets[index]);
                                          },
                                        ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Navbar
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
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      HomePage(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            child: Icon(
                              Icons.home_rounded,
                              color: primaryBlueColor,
                              size: 30,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
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
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
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
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: primaryBlueColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.api_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
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
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
