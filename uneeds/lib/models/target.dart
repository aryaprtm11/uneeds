class TargetPersonal {
  final int? id;
  final String namaTarget;
  final String jenisTarget;
  final String tanggalTarget;
  final String waktuTarget;
  final DateTime createdAt;
  final DateTime updatedAt;

  TargetPersonal({
    this.id,
    required this.namaTarget,
    required this.jenisTarget,
    required this.tanggalTarget,
    required this.waktuTarget,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  // Konversi dari Map (untuk membaca dari database)
  factory TargetPersonal.fromMap(Map<String, dynamic> map) {
    return TargetPersonal(
      id: map['id'] as int?,
      namaTarget: map['nama_target'] as String,
      jenisTarget: map['jenis_target'] as String,
      tanggalTarget: map['tanggal_target'] as String,
      waktuTarget: map['waktu_target'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Konversi ke Map (untuk menyimpan ke database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_target': namaTarget,
      'jenis_target': jenisTarget,
      'tanggal_target': tanggalTarget,
      'waktu_target': waktuTarget,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CapaianTarget {
  final int? id;
  final int idTarget;
  final String deskripsiCapaian;
  final int status; // 0 = belum selesai, 1 = selesai
  final DateTime createdAt;
  final DateTime updatedAt;

  CapaianTarget({
    this.id,
    required this.idTarget,
    required this.deskripsiCapaian,
    this.status = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  // Menambahkan method copyWith
  CapaianTarget copyWith({
    int? id,
    int? idTarget,
    String? deskripsiCapaian,
    int? status,
  }) {
    return CapaianTarget(
      id: id ?? this.id,
      idTarget: idTarget ?? this.idTarget,
      deskripsiCapaian: deskripsiCapaian ?? this.deskripsiCapaian,
      status: status ?? this.status,
    );
  }

  // Konversi dari Map (untuk membaca dari database)
  factory CapaianTarget.fromMap(Map<String, dynamic> map) {
    return CapaianTarget(
      id: map['id'] as int?,
      idTarget: map['id_target'] as int,
      deskripsiCapaian: map['deskripsi_capaian'] as String,
      status: map['status'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Konversi ke Map (untuk menyimpan ke database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_target': idTarget,
      'deskripsi_capaian': deskripsiCapaian,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
