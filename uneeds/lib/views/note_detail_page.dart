import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uneeds/models/note_model.dart';
import 'package:uneeds/views/tambah_catatan.dart';

class NoteDetailPage extends StatefulWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late Note _currentNote;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
  }

  Future<void> _navigateToEditPage() async {
    final resultFromEdit = await Navigator.push(
      // 'result' diganti nama jadi 'resultFromEdit'
      context,
      MaterialPageRoute(
        builder: (context) => TambahCatatanPage(noteToEdit: _currentNote),
      ),
    );

    if (resultFromEdit == true && mounted) {
      // **INI BAGIAN PENTING YANG DIPERBAIKI/DIAKTIFKAN**
      // Memberi sinyal kembali ke NotePage bahwa ada perubahan dan halaman ini (NoteDetailPage)
      // harus ditutup (pop) agar NotePage bisa mengambil alih dan me-refresh daftarnya.
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F9FF,
      ), // Anda bisa gunakan scaffoldBackgroundColor dari utils/color.dart jika ada
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color:
                primaryColor, // Menggunakan primaryColor dari utils/color.dart
          ),
          onPressed:
              () =>
                  Navigator.of(
                    context,
                  ).pop(), // Default pop jika tidak ada perubahan
        ),
        title: Text(
          _currentNote.title.isNotEmpty ? _currentNote.title : "Detail Catatan",
          style: const TextStyle(
            color:
                primaryColor, // Menggunakan primaryColor dari utils/color.dart
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: primaryColor,
            ), // Menggunakan primaryColor
            tooltip: "Edit Catatan",
            onPressed: _navigateToEditPage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _currentNote.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(
                  0xFF333333,
                ), // Anda bisa gunakan textColorPrimary dari utils/color.dart jika ada
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Dibuat pada: ${DateFormat('EEEE, dd MMM yyyy, HH:mm', 'id_ID').format(_currentNote.createdTime)}",
              style: TextStyle(
                fontSize: 13,
                color:
                    Colors
                        .grey[600], // Anda bisa gunakan textColorSecondary dari utils/color.dart jika ada
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            if (_currentNote.imagePath != null &&
                _currentNote.imagePath!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.file(
                      File(_currentNote.imagePath!),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.grey,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            SelectableText(
              _currentNote.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(
                  0xFF444444,
                ), // Sedikit lebih gelap dari textColorSecondary standar
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
