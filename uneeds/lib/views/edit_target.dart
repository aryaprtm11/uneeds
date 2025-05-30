import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Database Service
import 'package:uneeds/services/database_service.dart';

// Models
import 'package:uneeds/models/target.dart';

class EditTargetPage extends StatefulWidget {
  final TargetPersonal target;

  const EditTargetPage({super.key, required this.target});

  @override
  State<EditTargetPage> createState() => _EditTargetPageState();
}

class _EditTargetPageState extends State<EditTargetPage> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaTargetController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String _selectedJenisTarget = 'Beasiswa';

  List<TextEditingController> _listControllers = [];
  List<CapaianTarget> _listCapaianTarget = [];

  final List<String> _jenisTarget = [
    'Beasiswa',
    'Akademik',
    'Organisasi',
    'Kepanitiaan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();

    // Set nilai awal form dari data target yang diterima
    _namaTargetController.text = widget.target.namaTarget;
    _selectedJenisTarget = widget.target.jenisTarget;
    _deadlineController.text = widget.target.tanggalTarget;
    _timeController.text = widget.target.waktuTarget;

    _loadCapaian();
  }

  Future<void> _loadCapaian() async {
    final capaianList = await _databaseService.getCapaianTargetPersonal(
      widget.target.id!,
    );
    setState(() {
      _listCapaianTarget = capaianList;
      _listControllers = [];

      if (_listCapaianTarget.isNotEmpty) {
        for (var capaian in _listCapaianTarget) {
          final controller = TextEditingController(
            text: capaian.deskripsiCapaian,
          );
          _listControllers.add(controller);
        }
      } else {
        // Jika tidak ada capaian, buat 3 list kosong sebagai default
        _listControllers.addAll([
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ]);
      }
    });
  }

  @override
  void dispose() {
    _namaTargetController.dispose();
    _deadlineController.dispose();
    _timeController.dispose();
    for (var controller in _listControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2B4865),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2B4865),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _deadlineController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Fungsi untuk memilih waktu
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2B4865),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2B4865),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _timeController.text =
            "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan tombol back dan judul
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B4865),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Edit Target',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B4865),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nama Target',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2B4865),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _namaTargetController,
                            decoration: InputDecoration(
                              hintText: 'Beasiswa Bank Indonesia',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2B4865),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama target tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Jenis Target',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2B4865),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedJenisTarget,
                                isExpanded: true,
                                items:
                                    _jenisTarget.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedJenisTarget = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Tanggal Target Selesai',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2B4865),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _deadlineController,
                            readOnly: true,
                            onTap: _selectDate,
                            decoration: InputDecoration(
                              hintText: 'MM/DD/YYYY',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              suffixIcon: const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF2B4865),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2B4865),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Tanggal target tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Waktu Target Selesai',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2B4865),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _timeController,
                            readOnly: true,
                            onTap: _selectTime,
                            decoration: InputDecoration(
                              hintText: 'HH:MM',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              suffixIcon: const Icon(
                                Icons.access_time,
                                color: Color(0xFF2B4865),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2B4865),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Waktu target tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'List',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2B4865),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // List capaian input
                          ...List.generate(
                            _listControllers.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextFormField(
                                controller: _listControllers[index],
                                decoration: InputDecoration(
                                  hintText: 'List ${index + 1}',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 16,
                                  ),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF2B4865),
                                        width: 2,
                                      ),
                                    ),
                                    width: 24,
                                    height: 24,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF2B4865),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Tambah List Button
                          Container(
                            width: double.infinity,
                            height: 50,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _listControllers.add(TextEditingController());
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF2B4865),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Tambah List',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Simpan Button
              Container(
                width: double.infinity,
                height: 56,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // Update target
                        bool success = await _databaseService
                            .updateTargetPersonal(
                              widget.target.id!,
                              _namaTargetController.text,
                              _selectedJenisTarget,
                              _deadlineController.text,
                              _timeController.text,
                            );

                        if (success) {
                          // Hapus semua capaian lama
                          final oldCapaian = await _databaseService
                              .getCapaianTargetPersonal(widget.target.id!);
                          for (var capaian in oldCapaian) {
                            await _databaseService.deleteCapaian(capaian.id!);
                          }

                          // Tambah ulang capaian dari form
                          for (var controller in _listControllers) {
                            if (controller.text.isNotEmpty) {
                              await _databaseService.addCapaianTarget(
                                widget.target.id!,
                                controller.text,
                                0, // status belum selesai
                              );
                            }
                          }

                          Fluttertoast.showToast(
                            msg: 'Target berhasil diperbarui',
                          );
                          Navigator.pop(context, true);
                        } else {
                          Fluttertoast.showToast(
                            msg: 'Gagal memperbarui target',
                          );
                        }
                      } catch (e) {
                        print('Error updating target: $e');
                        Fluttertoast.showToast(
                          msg: 'Terjadi kesalahan saat memperbarui target',
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.save_outlined, color: Colors.white),
                  label: const Text(
                    'Simpan Target',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
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
    );
  }
}
