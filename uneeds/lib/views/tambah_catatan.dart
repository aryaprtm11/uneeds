import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:uneeds/services/database_service.dart';
import 'package:uneeds/models/note_model.dart';

// efinisi Warna Global
const Color primaryColor = Color(0xFF2B4865);
const Color accentColor = Color(0xFF00A8E8);
const Color scaffoldBackgroundColor = Color(0xFFF5F9FF);
const Color textColorPrimary = Color(0xFF333333);
const Color textColorSecondary = Color(0xFF555555);
const Color saveButtonColor = Color(0xFF2E7D32);

class TambahCatatanPage extends StatefulWidget {
  final Note? noteToEdit; // Parameter untuk mode edit

  const TambahCatatanPage({super.key, this.noteToEdit}); // Konstruktor diupdate

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  File? _gambar;
  String? _initialImagePath; // Untuk menyimpan path gambar awal saat edit
  bool _isLoading = false;
  bool get _isEditMode =>
      widget.noteToEdit != null; // Getter untuk cek mode edit

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      // Jika dalam mode edit, isi field dengan data note yang ada
      _judulController.text = widget.noteToEdit!.title;
      _catatanController.text = widget.noteToEdit!.content;
      if (widget.noteToEdit!.imagePath != null &&
          widget.noteToEdit!.imagePath!.isNotEmpty) {
        _gambar = File(widget.noteToEdit!.imagePath!);
        _initialImagePath = widget.noteToEdit!.imagePath;
      }
    }
  }

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
      String? finalImagePath = _gambar?.path;
      if (_isEditMode &&
          _gambar != null &&
          _gambar!.path == _initialImagePath) {
        // Jika gambar sama dengan yang awal (tidak diubah)
        finalImagePath = _initialImagePath;
      } else if (_isEditMode && _gambar == null && _initialImagePath != null) {
        // Jika gambar dihapus saat edit
        finalImagePath = null;
      }

      final noteUntukDisimpan = Note(
        id:
            _isEditMode
                ? widget.noteToEdit!.id
                : null, // Sertakan ID jika mode edit
        title: _judulController.text.trim(),
        content: _catatanController.text.trim(),
        imagePath: finalImagePath,
        createdTime:
            _isEditMode
                ? widget.noteToEdit!.createdTime
                : DateTime.now(), // Pertahankan createdTime asli saat edit
      );

      try {
        if (_isEditMode) {
          await DatabaseService.instance.updateNote(noteUntukDisimpan);
        } else {
          await DatabaseService.instance.addNote(noteUntukDisimpan);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode
                    ? "Catatan berhasil diperbarui."
                    : "Catatan berhasil disimpan.",
              ),
              backgroundColor: saveButtonColor,
            ),
          );
          Navigator.pop(context, true);
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
        scrolledUnderElevation: 2.0,
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
          _isEditMode ? 'Edit Catatan' : 'Tambah Catatan Baru',
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 80.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: saveButtonColor),
                  )
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _simpanCatatan,
                      icon: const Icon(
                        Icons.save_alt_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isEditMode
                            ? "Update Catatan"
                            : "Simpan Catatan", // Teks tombol dinamis
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: saveButtonColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: saveButtonColor.withOpacity(0.4),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
