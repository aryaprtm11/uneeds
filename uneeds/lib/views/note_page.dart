import 'package:flutter/material.dart';
// Utils
import 'package:uneeds/utils/color.dart';

// Views
import 'package:uneeds/views/home_page.dart';
import 'package:uneeds/views/schedule_page.dart';
import 'package:uneeds/views/tambah_catatan.dart';
import 'package:uneeds/views/target_page.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
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
                            'Catatan\nKuliah',
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
                                        (context) => const TambahCatatanPage(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                              label: const Text(
                                'Tambah',
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

                      // Search Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari catatan...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Implementasi future builder dengan return gridview builder
                      // Notes Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        itemCount:
                            5, // Banyak Data Catatan (Ganti dengan panjang data dinamis )
                        itemBuilder: (context, index) {
                          return _buildNoteCard(
                            title: 'Catatan ${index + 1}',
                            date:
                                '12 Mar 2024', // Ganti dengan tanggal catatan dari database
                            content:
                                // Ganti dengan isi catatan dari database
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                            color:
                                index % 2 == 0
                                    ? const Color(0xFF2B4865)
                                    : const Color(0xFF4A7B97),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Navbar dan tombol plus
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
                        false,
                      ),
                      _navIcon(
                        context,
                        Icons.view_list_rounded,
                        NotePage(),
                        true,
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
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Notes Card
  Widget _buildNoteCard({
    required String title,
    required String date,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navIcon(
    BuildContext context,
    IconData icon,
    Widget page,
    bool isActive,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
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
