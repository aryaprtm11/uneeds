import 'package:flutter/material.dart';

// Toast
import 'package:fluttertoast/fluttertoast.dart';

// Database
import 'package:uneeds/services/database_service.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  // Database Instance
  final DatabaseService _databaseService = DatabaseService.instance;

  final _formKey = GlobalKey<FormState>();
  String selectedDay = 'Senin';
  String selectedCategory = 'Wajib';

  // Controller untuk input waktu
  final TextEditingController _startHourController = TextEditingController(
    text: '00',
  );
  final TextEditingController _startMinuteController = TextEditingController(
    text: '00',
  );
  final TextEditingController _endHourController = TextEditingController(
    text: '00',
  );
  final TextEditingController _endMinuteController = TextEditingController(
    text: '00',
  );

  // Controller untuk input matkul,dosen,dan ruangan
  final TextEditingController _matkulController = TextEditingController();
  final TextEditingController _dosenController = TextEditingController();
  final TextEditingController _ruanganController = TextEditingController();

  final List<String> _categories = ['Wajib', 'Pilihan', 'Praktikum'];

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
      backgroundColor: const Color(0xFFF5F9FF),
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
                      'Tambah Jadwal',
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

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _saveSchedule,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Simpan Jadwal',
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
    String? Function(String?)? validator,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2B4865)),
        ),
      ),
    );
  }

  Widget _buildDropdownButton({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(8),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
        ),
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
              if (hour == null || hour < 0 || hour > 23)
                return 'Jam harus antara 0-23';
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
              if (minute == null || minute < 0 || minute > 59)
                return 'Menit harus antara 0-59';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Future<void> _saveSchedule() async {
    // Tambahkan async jika addJadwal asinkron
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

      // Tambahkan validasi waktu di sini jika diperlukan
      if (startTime.compareTo(endTime) >= 0) {
        Fluttertoast.showToast(msg: 'Waktu mulai harus sebelum waktu berakhir');
        return;
      }

      try {
        // Jika addJadwal mengembalikan Future, gunakan await
        await _databaseService.addJadwal(
          _matkulController.text,
          _dosenController.text,
          selectedDay,
          _ruanganController.text,
          startTime,
          endTime,
          selectedCategory,
        );
        Fluttertoast.showToast(msg: 'Jadwal berhasil disimpan');
        setState(() {
          _matkulController.clear();
          _dosenController.clear();
          _ruanganController.clear();
          _startHourController.clear();
          _startMinuteController.clear();
          _endHourController.clear();
          _endMinuteController.clear();
        });
        Navigator.pop(context);
      } catch (e) {
        Fluttertoast.showToast(msg: 'Terjadi kesalahan saat menyimpan jadwal');
        print('Error saving schedule: $e'); // Log error untuk debugging
      }
    }
  }
}
