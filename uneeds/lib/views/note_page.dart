import 'dart:io'; // Untuk File (menampilkan gambar)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

// Models
import 'package:uneeds/models/note_model.dart'; // Sesuaikan path jika perlu

// Services
import 'package:uneeds/services/database_service.dart'; // <- PERUBAHAN DI SINI

// Utils
import 'package:uneeds/utils/color.dart'; // Asumsi primaryBlueColor dari sini

// Views
import 'package:uneeds/views/home_page.dart';
import 'package:uneeds/views/note_detail_page.dart';
import 'package:uneeds/views/schedule_page.dart';
import 'package:uneeds/views/tambah_catatan.dart';
import 'package:uneeds/views/target_page.dart';

// const Color primaryBlueColor = Color(0xFF2B4865); // Jika tidak diimpor dari utils/color.dart
const Color cardColor1 = Color(0xFF2B4865); // Warna kartu ganjil
const Color cardColor2 = Color(0xFF4A7B97); // Warna kartu genap

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late List<Note> _notes;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<Note> _filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _notes = [];
    _filteredNotes = [];
    _refreshNotes();
    _searchController.addListener(_filterNotes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterNotes);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshNotes() async {
    setState(() {
      _isLoading = true;
    });
    // Menggunakan DatabaseService.instance
    final data = await DatabaseService.instance.getAllNotes();
    setState(() {
      _notes = data;
      _filterNotes(); // Terapkan filter setelah refresh
      _isLoading = false;
    });
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = List.from(_notes);
      } else {
        _filteredNotes =
            _notes.where((note) {
              return note.title.toLowerCase().contains(query) ||
                  note.content.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  Future<void> _navigateToTambahCatatan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahCatatanPage()),
    );

    if (result == true && mounted) {
      _refreshNotes();
    }
  }

  Future<void> _navigateToEditCatatan(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahCatatanPage(noteToEdit: note),
      ),
    );

    if (result == true && mounted) {
      _refreshNotes();
    }
    print("Navigasi ke edit catatan: ${note.title}");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Catatan berhasil diperbarui.")),
    );
  }

  Future<void> _deleteNote(int id) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Hapus Catatan?'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus catatan ini?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmDelete == true) {
      // Menggunakan DatabaseService.instance dan metode deleteNote
      await DatabaseService.instance.deleteNote(id);
      _refreshNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Catatan berhasil dihapus."),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F9FF,
      ), // Pastikan ini sesuai dengan scaffoldBackgroundColor Anda jika ada
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: _refreshNotes,
                color: primaryBlueColor, // Dari utils/color.dart
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                                height: 1.1,
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: _navigateToTambahCatatan,
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 22,
                              ),
                              label: const Text(
                                'Tambah',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    primaryBlueColor, // Dari utils/color.dart
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Cari catatan...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[400],
                                size: 22,
                              ),
                              suffixIcon:
                                  _searchController.text.isNotEmpty
                                      ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.grey[400],
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                      )
                                      : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                ), // Dari utils/color.dart
                              ),
                            )
                            : _filteredNotes.isEmpty
                            ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 50.0,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.note_alt_outlined,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _searchController.text.isEmpty &&
                                              _notes.isEmpty
                                          ? 'Belum ada catatan.\nAyo buat yang pertama!'
                                          : 'Tidak ada catatan ditemukan.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.7,
                                  ),
                              itemCount: _filteredNotes.length,
                              itemBuilder: (context, index) {
                                final note = _filteredNotes[index];
                                return _buildNoteCard(
                                  note: note,
                                  color:
                                      index % 2 == 0 ? cardColor1 : cardColor2,
                                  onTap: () {
                                    // <<<---- UBAH INI
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                NoteDetailPage(note: note),
                                      ),
                                    ).then((value) {
                                      // Jika NoteDetailPage memberi sinyal untuk refresh (misalnya setelah edit dari sana)
                                      if (value == true) {
                                        _refreshNotes();
                                      }
                                    });
                                  },
                                  onEdit:
                                      () => _navigateToEditCatatan(
                                        note,
                                      ), // Ini tetap bisa langsung ke edit
                                  onDelete: () => _deleteNote(note.id!),
                                );
                              },
                            ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom
                      : 20,
              top: 10,
              left: 20,
              right: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.65,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlueColor.withOpacity(
                          0.1,
                        ), // Dari utils/color.dart
                        spreadRadius: 0,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _navIcon(
                        context,
                        Icons.home_rounded,
                        const HomePage(),
                        false,
                        'Home',
                      ),
                      _navIcon(
                        context,
                        Icons.calendar_today_rounded,
                        const SchedulePage(),
                        false,
                        'Jadwal',
                      ),
                      _navIcon(
                        context,
                        Icons.view_list_rounded,
                        const NotePage(),
                        true,
                        'Catatan',
                      ),
                      _navIcon(
                        context,
                        Icons.bar_chart_rounded,
                        const TargetPage(),
                        false,
                        'Target',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _navigateToTambahCatatan,
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: primaryBlueColor, // Dari utils/color.dart
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlueColor.withOpacity(
                            0.3,
                          ), // Dari utils/color.dart
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
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

  Widget _buildNoteCard({
    required Note note,
    required Color color,
    VoidCallback? onTap,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.imagePath != null && note.imagePath!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Image.file(
                  File(note.imagePath!),
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            if (note.imagePath != null && note.imagePath!.isNotEmpty)
              const SizedBox(height: 8),
            Text(
              note.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              maxLines:
                  (note.imagePath != null && note.imagePath!.isNotEmpty)
                      ? 1
                      : 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat(
                'dd MMM yyyy, HH:mm',
              ).format(note.createdTime), // Format tanggal lebih lengkap
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                note.content,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  height: 1.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines:
                    (note.imagePath != null && note.imagePath!.isNotEmpty)
                        ? 2
                        : 4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(
                      Icons.edit_note_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      padding: const EdgeInsets.all(6),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onEdit,
                    tooltip: "Edit",
                  ),
                if (onEdit != null && onDelete != null)
                  const SizedBox(width: 4),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      padding: const EdgeInsets.all(6),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onDelete,
                    tooltip: "Hapus",
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(
    BuildContext context,
    IconData icon,
    Widget page,
    bool isActive,
    String tooltipMessage,
  ) {
    return Tooltip(
      message: tooltipMessage,
      child: InkWell(
        onTap:
            isActive
                ? null
                : () {
                  if (page is NotePage && isActive) return;
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) => page,
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 200),
                    ),
                  );
                },
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
                isActive
                    ? primaryBlueColor
                    : Colors.transparent, // Dari utils/color.dart
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color:
                isActive
                    ? Colors.white
                    : primaryBlueColor.withOpacity(
                      0.8,
                    ), // Dari utils/color.dart
            size: 26,
          ),
        ),
      ),
    );
  }
}
