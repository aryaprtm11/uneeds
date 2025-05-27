import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:uneeds/services/database_service.dart'; // Diasumsikan ini ada

// --- Placeholder untuk DatabaseService ---
// Ganti dengan implementasi DatabaseService Anda yang sebenarnya
class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  Future<void> insertCatatan(
    String judul,
    String teks,
    String? pathGambar,
  ) async {
    // Logika untuk menyimpan catatan ke database
    print('Menyimpan catatan:');
    print('Judul: $judul');
    print('Teks: $teks');
    print('Path Gambar: $pathGambar');
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Simulasi operasi database
  }
}
// --- Akhir Placeholder ---

// --- Definisi Warna Global (Contoh, sesuaikan dengan tema aplikasi Anda) ---
const Color primaryColor = Color(
  0xFF2B4865,
); // Biru gelap dari contoh sebelumnya
const Color accentColor = Color(0xFF00A8E8); // Biru muda sebagai aksen
const Color scaffoldBackgroundColor = Color(0xFFF5F9FF);
const Color textColorPrimary = Color(0xFF333333);
const Color textColorSecondary = Color(0xFF555555);
const Color saveButtonColor = Color(
  0xFF2E7D32,
); // Warna hijau untuk tombol simpan
// --- Akhir Definisi Warna Global ---

class TambahCatatanPage extends StatefulWidget {
  // Jika Anda ingin halaman ini juga untuk mode edit, tambahkan parameter note
  // final YourNoteModel? noteToEdit;
  // const TambahCatatanPage({super.key, this.noteToEdit});

  const TambahCatatanPage({super.key});

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  File? _gambar;
  bool _isLoading = false;

  // @override
  // void initState() {
  //   super.initState();
  //   if (widget.noteToEdit != null) {
  //     _judulController.text = widget.noteToEdit!.judul;
  //     _catatanController.text = widget.noteToEdit!.isi;
  //     // _gambar = widget.noteToEdit!.gambar != null ? File(widget.noteToEdit!.gambar!) : null;
  //   }
  // }

  Future<void> _pilihGambar(ImageSource source) async {
    if (_isLoading) return;
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _gambar = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tidak dapat mengakses gambar: $e")),
        );
      }
    }
  }

  void _hapusGambar() {
    setState(() {
      _gambar = null;
    });
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: primaryColor,
                ),
                title: const Text(
                  'Pilih dari Galeri',
                  style: TextStyle(color: textColorPrimary),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pilihGambar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: primaryColor,
                ),
                title: const Text(
                  'Ambil Foto dengan Kamera',
                  style: TextStyle(color: textColorPrimary),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pilihGambar(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _simpanCatatan() async {
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await DatabaseService.instance.insertCatatan(
          _judulController.text.trim(),
          _catatanController.text.trim(),
          _gambar?.path,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Catatan berhasil disimpan."),
              backgroundColor:
                  saveButtonColor, // Menggunakan warna tombol simpan untuk sukses
            ),
          );
          Navigator.pop(context, true); // Kirim 'true' untuk indikasi sukses
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menyimpan catatan: ${e.toString()}"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        scrolledUnderElevation:
            2.0, // Memberi sedikit efek shadow saat di-scroll
        shadowColor: primaryColor.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: "Kembali",
        ),
        title: Text(
          // widget.noteToEdit == null ? 'Tambah Catatan Baru' : 'Edit Catatan',
          'Tambah Catatan Baru',
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        // Tombol simpan di AppBar dihapus dari sini
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20.0,
          20.0,
          20.0,
          80.0,
        ), // Tambah padding bawah untuk tombol
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Field Judul ---
              TextFormField(
                controller: _judulController,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textColorPrimary,
                ),
                decoration: InputDecoration(
                  labelText: "Judul Catatan",
                  labelStyle: const TextStyle(color: primaryColor),
                  hintText: "Mis: Ringkasan Bab 3 Algo",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong.';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // --- Field Isi Catatan ---
              TextFormField(
                controller: _catatanController,
                maxLines: 8,
                minLines: 5,
                style: const TextStyle(
                  fontSize: 15,
                  color: textColorSecondary,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  labelText: "Isi Catatan",
                  labelStyle: const TextStyle(color: primaryColor),
                  hintText: "Tulis catatan detailmu di sini...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Isi catatan tidak boleh kosong.';
                  }
                  return null;
                },
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 24),

              // --- Pilihan Gambar ---
              Text(
                "Tambahkan Gambar (Opsional)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _isLoading ? null : _showImageSourceDialog,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _gambar != null
                              ? accentColor.withOpacity(0.5)
                              : Colors.grey[350]!,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child:
                      _gambar != null
                          ? Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.file(
                                  _gambar!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: InkWell(
                                  onTap: _isLoading ? null : _hapusGambar,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Ketuk untuk memilih gambar",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 30), // Jarak sebelum tombol simpan
              // --- Tombol Simpan ---
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: saveButtonColor),
                  )
                  : SizedBox(
                    width: double.infinity, // Tombol memenuhi lebar
                    child: ElevatedButton.icon(
                      onPressed: _simpanCatatan,
                      icon: const Icon(
                        Icons.save_alt_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Simpan Catatan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            saveButtonColor, // Warna hijau yang diminta
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: saveButtonColor.withOpacity(0.4),
                      ),
                    ),
                  ),
              // SizedBox tambahan di bawah tidak begitu diperlukan karena SingleChildScrollView punya padding bawah
            ],
          ),
        ),
      ),
    );
  }
}
