import 'package:flutter/material.dart';

// Toast
import 'package:fluttertoast/fluttertoast.dart';

// Database
import 'package:uneeds/services/database_service.dart';

// Models
import 'package:uneeds/models/jadwal.dart';

class EditSchedulePage extends StatefulWidget {
  final Jadwal jadwal;
  const EditSchedulePage({required this.jadwal, super.key});

  @override
  State<EditSchedulePage> createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> {
  // Database Instance
  final DatabaseService _databaseService = DatabaseService.instance;

  final _formKey = GlobalKey<FormState>();
  late String selectedDay;
  late String selectedCategory;

  // Controller untuk input waktu
  late TextEditingController _startHourController;
  late TextEditingController _startMinuteController;
  late TextEditingController _endHourController;
  late TextEditingController _endMinuteController;

  // Controller untuk input matkul, dosen, dan ruangan
  late TextEditingController _matkulController;
  late TextEditingController _dosenController;
  late TextEditingController _ruanganController;

  final List<String> _categories = ['Wajib', 'Pilihan', 'Praktikum'];

  @override
  void initState() {
    super.initState();
    // Inisialisasi data dari jadwal yang ada
    selectedDay = widget.jadwal.hari;
    selectedCategory = widget.jadwal.kategori;

    // Inisialisasi waktu
    final startTimeParts = widget.jadwal.waktuMulai.split(':');
    final endTimeParts = widget.jadwal.waktuSelesai.split(':');

    _startHourController = TextEditingController(text: startTimeParts[0]);
    _startMinuteController = TextEditingController(text: startTimeParts[1]);
    _endHourController = TextEditingController(text: endTimeParts[0]);
    _endMinuteController = TextEditingController(text: endTimeParts[1]);

    // Inisialisasi data lainnya
    _matkulController = TextEditingController(text: widget.jadwal.matkul);
    _dosenController = TextEditingController(text: widget.jadwal.dosen);
    _ruanganController = TextEditingController(text: widget.jadwal.ruangan);
  }

  @override
  void dispose() {
    _startHourController.dispose();
    _startMinuteController.dispose();
    _endHourController.dispose();
    _endMinuteController.dispose();
    _matkulController.dispose();
    _dosenController.dispose();
    _ruanganController.dispose();
    super.dispose();
  }

  // Memformat Waktu
  String formatTime24(String hourText, String minuteText) {
    int hour = int.tryParse(hourText) ?? 0;
    int minute = int.tryParse(minuteText) ?? 0;

    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');

    return '$hourStr:$minuteStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button and title
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B4865),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Edit Jadwal',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2B4865),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form Container
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Nama Mata Kuliah'),
                          _buildTextField(
                            controller: _matkulController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama mata kuliah tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildInputLabel('Dosen Pengampu'),
                          _buildTextField(
                            controller: _dosenController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama dosen tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildInputLabel('Ruangan Kelas'),
                          _buildTextField(
                            controller: _ruanganController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ruangan kelas tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildInputLabel('Hari'),
                          _buildDropdownButton(
                            value: selectedDay,
                            items: const [
                              'Senin',
                              'Selasa',
                              'Rabu',
                              'Kamis',
                              'Jumat',
                              'Sabtu',
                              'Minggu',
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedDay = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Time Selection
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInputLabel('Waktu Mulai'),
                                    _buildTimeInput(
                                      hourController: _startHourController,
                                      minuteController: _startMinuteController,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInputLabel('Waktu Berakhir'),
                                    _buildTimeInput(
                                      hourController: _endHourController,
                                      minuteController: _endMinuteController,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildInputLabel('Kategori Jadwal'),
                          _buildDropdownButton(
                            value: selectedCategory,
                            items: _categories,
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Row untuk tombol Simpan dan Hapus
                Row(
                  children: [
                    // Tombol Hapus
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _deleteSchedule,
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text(
                            'Hapus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tombol Simpan
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _updateSchedule,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Simpan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B4865),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2B4865),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF2B4865),
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2B4865)),
        ),
      ),
    );
  }

  Widget _buildDropdownButton({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF2B4865),
        ),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTimeInput({
    required TextEditingController hourController,
    required TextEditingController minuteController,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hours
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: hourController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2B4865),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Jam harus diisi';
              final hour = int.tryParse(value);
              if (hour == null || hour < 0 || hour > 23) {
                return 'Jam harus antara 0-23';
              }
              return null;
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            ':',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        // Minutes
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: minuteController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2B4865),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Menit harus diisi';
              final minute = int.tryParse(value);
              if (minute == null || minute < 0 || minute > 59) {
                return 'Menit harus antara 0-59';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Future<void> _updateSchedule() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCategory.isEmpty ||
          selectedDay.isEmpty ||
          _matkulController.text.isEmpty ||
          _dosenController.text.isEmpty ||
          _ruanganController.text.isEmpty) {
        Fluttertoast.showToast(msg: 'Semua field harus diisi');
        return;
      }

      final startTime = formatTime24(
        _startHourController.text,
        _startMinuteController.text,
      );

      final endTime = formatTime24(
        _endHourController.text,
        _endMinuteController.text,
      );

      // Validasi waktu
      if (startTime.compareTo(endTime) >= 0) {
        Fluttertoast.showToast(msg: 'Waktu mulai harus sebelum waktu berakhir');
        return;
      }

      try {
        await _databaseService.updateJadwal(
          widget.jadwal.id, // Perlu menambahkan id di model Jadwal
          _matkulController.text,
          _dosenController.text,
          selectedDay,
          _ruanganController.text,
          startTime,
          endTime,
          selectedCategory,
        );
        Fluttertoast.showToast(msg: 'Jadwal berhasil diperbarui');
        Navigator.pop(context, true); // Mengirim sinyal bahwa data telah diupdate
      } catch (e) {
        Fluttertoast.showToast(msg: 'Terjadi kesalahan saat memperbarui jadwal');
        print('Error updating schedule: $e');
      }
    }
  }

  Future<void> _deleteSchedule() async {
    // Tampilkan dialog konfirmasi
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    // Jika user mengkonfirmasi
    if (confirm == true) {
      try {
        bool success = await _databaseService.deleteJadwal(widget.jadwal.id);
        if (success) {
          Fluttertoast.showToast(msg: 'Jadwal berhasil dihapus');
          Navigator.pop(context, true); // Kembali ke halaman sebelumnya dengan status berhasil
        } else {
          Fluttertoast.showToast(msg: 'Gagal menghapus jadwal');
        }
      } catch (e) {
        Fluttertoast.showToast(msg: 'Terjadi kesalahan saat menghapus jadwal');
        print('Error deleting schedule: $e');
      }
    }
  }
} 