import 'package:flutter/material.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  String selectedDay = 'Senin';
  String selectedCategory = 'Wajib';
  
  // Controller untuk input teks
  final TextEditingController _startHourController = TextEditingController(text: '00');
  final TextEditingController _startMinuteController = TextEditingController(text: '00');
  final TextEditingController _endHourController = TextEditingController(text: '00');
  final TextEditingController _endMinuteController = TextEditingController(text: '00');
  
  bool isAM = true;
  bool isAMEnd = true;

  final List<String> _categories = ['Wajib', 'Pilihan', 'Praktikum'];

  @override
  void dispose() {
    _startHourController.dispose();
    _startMinuteController.dispose();
    _endHourController.dispose();
    _endMinuteController.dispose();
    super.dispose();
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
                            items: const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'],
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
                                      isAM: isAM,
                                      onAMPMChanged: (value) {
                                        setState(() {
                                          isAM = value;
                                        });
                                      },
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
                                      isAM: isAMEnd,
                                      onAMPMChanged: (value) {
                                        setState(() {
                                          isAMEnd = value;
                                        });
                                      },
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
  }) {
    return TextFormField(
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTimeInput({
    required TextEditingController hourController,
    required TextEditingController minuteController,
    required bool isAM,
    required Function(bool) onAMPMChanged,
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
              if (value == null || value.isEmpty) return '';
              final hour = int.tryParse(value);
              if (hour == null || hour < 0 || hour > 23) return '';
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            ':',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
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
              if (value == null || value.isEmpty) return '';
              final minute = int.tryParse(value);
              if (minute == null || minute < 0 || minute > 59) return '';
              return null;
            },
          ),
        ),
      ],
    );
  }

  void _saveSchedule() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save schedule logic
      Navigator.pop(context);
    }
  }
} 