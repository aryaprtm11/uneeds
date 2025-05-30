import 'package:flutter/material.dart';

// Utils
import 'package:uneeds/utils/color.dart';

// Views
import 'package:uneeds/views/home_page.dart';
import 'package:uneeds/views/note_page.dart';
import 'package:uneeds/views/schedule_page.dart';
import 'package:uneeds/views/add_target.dart';
import 'package:uneeds/views/edit_target.dart';

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
      _loadTargets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTargets() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Load semua target terlebih dahulu
      final targets = await _databaseService.getAllTargets();

      if (!mounted) return;

      // Memproses capaian untuk setiap target secara parallel
      final futures = targets.map((target) async {
        final capaian = await _databaseService.getCapaianByTargetId(target.id!);
        return MapEntry(target.id!, capaian);
      });

      final capaianResults = await Future.wait(futures);

      if (!mounted) return;

      final activeTargets = <TargetPersonal>[];
      final completedTargets = <TargetPersonal>[];
      final capaianMap = Map.fromEntries(capaianResults);

      // Memproses status target
      for (var target in targets) {
        final capaian = capaianMap[target.id] ?? [];
        bool isCompleted = capaian.every((c) => c.status == 1);
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
    if (_isProcessing) return; // Prevent multiple simultaneous updates

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
        // Update local state first
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

          // Check if all capaian are completed
          final allCompleted = capaianList.every((c) => c.status == 1);
          if (allCompleted) {
            final target = _activeTargets.firstWhere((t) => t.id == targetId);
            setState(() {
              _activeTargets.remove(target);
              _completedTargets.add(target);
            });
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

  Widget _buildTargetCard(TargetPersonal target) {
    final capaianList = _capaianTargets[target.id] ?? [];
    final completedCount = capaianList.where((c) => c.status == 1).length;

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
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    capaian.status == 1
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFF2B4865),
                                width: 2,
                              ),
                              color:
                                  capaian.status == 1
                                      ? const Color(0xFF2E7D32)
                                      : Colors.white,
                            ),
                            child:
                                capaian.status == 1
                                    ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _toggleCapaian(capaian),
                              child: Text(
                                capaian.deskripsiCapaian,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      capaian.status == 1
                                          ? Colors.grey
                                          : Colors.black87,
                                  decoration:
                                      capaian.status == 1
                                          ? TextDecoration.lineThrough
                                          : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2B4865)),
              onPressed: () {
                // TODO: Implement edit functionality
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditTargetPage(target: target),
                  ),
                );
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
      backgroundColor: const Color(0xFFF5F9FF),
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
                                          builder:
                                              (context) =>
                                                  const AddTargetPage(),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadTargets();
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                _activeTargets.length
                                                    .toString(),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons
                                                  .check_circle_outline_rounded,
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
                                                _completedTargets.length
                                                    .toString(),
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
                        child:
                            _isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF2B4865),
                                  ),
                                )
                                : TabBarView(
                                  controller: _tabController,
                                  physics:
                                      const NeverScrollableScrollPhysics(), // Disable swipe
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
                                            return _buildTargetCard(
                                              _activeTargets[index],
                                            );
                                          },
                                        ),

                                    // Tab Target Selesai
                                    _completedTargets.isEmpty
                                        ? const Center(
                                          child: Text(
                                            'Belum ada target selesai',
                                          ),
                                        )
                                        : ListView.builder(
                                          padding: const EdgeInsets.all(20),
                                          itemCount: _completedTargets.length,
                                          itemBuilder: (context, index) {
                                            return _buildTargetCard(
                                              _completedTargets[index],
                                            );
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
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => HomePage(),
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
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => SchedulePage(),
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
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => NotePage(),
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
