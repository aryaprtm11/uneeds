import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Models
import 'package:uneeds/models/jadwal.dart';
import 'package:uneeds/models/catatan.dart';
import 'package:uneeds/models/target.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  // Nama Tabel
  static const String tableJadwal = 'jadwal';
  static const String tableTargetPersonal = 'target_personal';
  static const String tableCapaian = 'capaian';
  static const String tableCatatanMateri = 'catatan_materi';
  static const String tableGambarCatatan = 'gambar_catatan';
  static const String tableUser = 'user';

  // Kolom Tabel Jadwal
  static const String columnIdJadwal = 'id_jadwal';
  static const String columnMatkul = 'matkul';
  static const String columnDosen = 'dosen';
  static const String columnHari = 'hari';
  static const String columnRuangan = 'ruangan';
  static const String columnWaktuMulai = 'waktu_mulai';
  static const String columnWaktuSelesai = 'waktu_selesai';
  static const String columnKategori = 'kategori';
  static const String columnCreatedAt = 'createdAt';

  // Kolom tabel catatan
  static const String columnIdCatatan = 'id_catatan';
  static const String columnJudulCatatan = 'judul_catatan';
  static const String columnIsiCatatan = 'isi_catatan';
  static const String columnGambarCatatan = 'gambar';
  static const String columnCreatedAtCatatan = 'createdAtCatatan';

  // Kolom tabel target personal
  static const String columnJudulTargetPersonal = 'judul_target';
  static const String columnDeadlineTargetPersonal = 'deadline';

  // Kolom tabel capaian
  static const String columnIdTarget = 'id_target';
  static const String columnDeskripsiCapaian = 'deskripsi_capaian';
  static const String columnStatusCapaian = 'status';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _getDatabase();
    return _database!;
  }

  Future<Database> _getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "uneeds.db");
    final database = await openDatabase(
      databasePath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableJadwal (
            $columnIdJadwal INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnMatkul VARCHAR NOT NULL,
            $columnDosen VARCHAR NOT NULL,
            $columnHari VARCHAR NOT NULL,
            $columnRuangan VARCHAR NOT NULL,
            $columnWaktuMulai STRING NOT NULL,
            $columnWaktuSelesai STRING NOT NULL,
            $columnKategori VARCHAR NOT NULL,
            $columnCreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )''');
        await db.execute('''
          CREATE TABLE $tableTargetPersonal (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama_target VARCHAR NOT NULL,
            jenis_target VARCHAR NOT NULL,
            tanggal_target VARCHAR NOT NULL,
            waktu_target VARCHAR NOT NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )''');
        await db.execute('''
          CREATE TABLE $tableCapaian (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_target INTEGER NOT NULL,
            deskripsi_capaian VARCHAR NOT NULL,
            status INTEGER NOT NULL DEFAULT 0,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (id_target) REFERENCES $tableTargetPersonal(id) ON DELETE CASCADE
          )''');
        await db.execute('''
          CREATE TABLE $tableCatatanMateri (
            id_catatan INTEGER PRIMARY KEY AUTOINCREMENT,
            judul_catatan TEXT,
            isi_catatan TEXT,
            waktu_catatan TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
        ''');
        await db.execute('''
          CREATE TABLE $tableGambarCatatan (
            id_gambar INTEGER PRIMARY KEY AUTOINCREMENT,
            id_catatan INTEGER NOT NULL,
            gambar STRING NOT NULL,
            createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (id_catatan) REFERENCES $tableCatatanMateri(id_catatan) ON DELETE CASCADE
          )''');
        await db.execute('''
          CREATE TABLE $tableUser (
            id_user VARCHAR PRIMARY KEY NOT NULL,
            email VARCHAR NOT NULL,
            username VARCHAR NOT NULL
          )''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Drop tabel lama
          await db.execute('DROP TABLE IF EXISTS $tableTargetPersonal');
          await db.execute('DROP TABLE IF EXISTS $tableCapaian');

          // Buat tabel baru
          await db.execute('''
            CREATE TABLE $tableTargetPersonal (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nama_target VARCHAR NOT NULL,
              jenis_target VARCHAR NOT NULL,
              tanggal_target VARCHAR NOT NULL,
              waktu_target VARCHAR NOT NULL,
              created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
              updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
            )''');
          await db.execute('''
            CREATE TABLE $tableCapaian (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_target INTEGER NOT NULL,
              deskripsi_capaian VARCHAR NOT NULL,
              status INTEGER NOT NULL DEFAULT 0,
              created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
              updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
              FOREIGN KEY (id_target) REFERENCES $tableTargetPersonal(id) ON DELETE CASCADE
            )''');
        }
      },
    );
    return database;
  }

  /* Controller Jadwal */

  // Add Jadwal
  Future<bool> addJadwal(
    String matkul,
    String dosen,
    String hari,
    String ruangan,
    String waktuMulai,
    String waktuSelesai,
    String kategori,
  ) async {
    try {
      final db = await database;
      await db.insert(tableJadwal, {
        columnMatkul: matkul,
        columnDosen: dosen,
        columnHari: hari,
        columnRuangan: ruangan,
        columnWaktuMulai: waktuMulai,
        columnWaktuSelesai: waktuSelesai,
        columnKategori: kategori,
      });
      return true;
    } catch (e) {
      print('Error adding jadwal: $e');
      return false;
    }
  }

  // Update Jadwal
  Future<bool> updateJadwal(
    int id,
    String matkul,
    String dosen,
    String hari,
    String ruangan,
    String waktuMulai,
    String waktuSelesai,
    String kategori,
  ) async {
    try {
      final db = await database;
      await db.update(
        tableJadwal,
        {
          columnMatkul: matkul,
          columnDosen: dosen,
          columnHari: hari,
          columnRuangan: ruangan,
          columnWaktuMulai: waktuMulai,
          columnWaktuSelesai: waktuSelesai,
          columnKategori: kategori,
        },
        where: '$columnIdJadwal = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error updating jadwal: $e');
      return false;
    }
  }

  // Get data jadwal
  Future<List<Jadwal>> getJadwal() async {
    final db = await database;
    final data = await db.query(tableJadwal);
    List<Jadwal> jadwal =
        data
            .map(
              (e) => Jadwal(
                id: e["id_jadwal"] as int,
                matkul: e["matkul"] as String,
                dosen: e["dosen"] as String,
                hari: e["hari"] as String,
                ruangan: e["ruangan"] as String,
                waktuMulai: e["waktu_mulai"] as String,
                waktuSelesai: e["waktu_selesai"] as String,
                kategori: e["kategori"] as String,
              ),
            )
            .toList();

    return jadwal;
  }

  // Delete Jadwal
  Future<bool> deleteJadwal(int id) async {
    try {
      final db = await database;
      await db.delete(
        tableJadwal,
        where: '$columnIdJadwal = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Error deleting jadwal: $e');
      return false;
    }
  }

  /* Controller Catatan */

  // Add Isi Catatan
  Future<bool> addCatatan(String judulCatatan, String isiCatatan) async {
    try {
      final db = await database;
      await db.insert(tableCatatanMateri, {
        columnJudulCatatan: judulCatatan,
        columnIsiCatatan: isiCatatan,
      });
      return true;
    } catch (e) {
      print('Error adding Catatan: $e');
      return false;
    }
  }

  // Add Gambar Catatan
  Future<bool> addGambarCatatan(int idCatatan, String gambarCatatan) async {
    try {
      final db = await database;
      await db.insert(tableGambarCatatan, {
        columnIdCatatan: idCatatan,
        columnGambarCatatan: gambarCatatan,
      });
      return true;
    } catch (e) {
      print('Error adding Gambar Catatan: $e');
      return false;
    }
  }

  // Get Data Catatan
  Future<List<Catatan>> getCatatan() async {
    try {
      final db = await database;
      final data = await db.query(tableCatatanMateri);
      List<Catatan> catatan =
          data
              .map(
                (e) => Catatan(
                  judulCatatan: e["judul_catatan"] as String,
                  isiCatatan: e["isi_catatan"] as String,
                ),
              )
              .toList();

      return catatan;
    } catch (e) {
      print('Error getting Catatan: $e');
      return [];
    }
  }

  // Get Data Gambar Catatan
  Future<List<GambarCatatan>> getGambarCatatan(int idCatatan) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> data = await db.query(
        tableGambarCatatan,
        where: 'id_catatan = ?',
        whereArgs: [
          idCatatan, //Protect From SQL Injection
        ],
      );
      List<GambarCatatan> gambarCatatan =
          data
              .map(
                (e) => GambarCatatan(
                  idCatatan: idCatatan,
                  gambarCatatan: e["gambar"] as String,
                ),
              )
              .toList();

      return gambarCatatan;
    } catch (e) {
      print('Error getting Gambar Catatan: $e');
      return [];
    }
  }

  /* Controller Target Personal */

  // Add Target Personal
  Future<bool> addTargetPersonal(
    String namaTarget,
    String jenisTarget,
    String tanggalTarget,
    String waktuTarget,
  ) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      
      final id = await db.insert(
        tableTargetPersonal,
        {
          'nama_target': namaTarget,
          'jenis_target': jenisTarget,
          'tanggal_target': tanggalTarget,
          'waktu_target': waktuTarget,
          'created_at': now,
          'updated_at': now,
        },
      );
      return id > 0;
    } catch (e) {
      print('Error adding target: $e');
      return false;
    }
  }

  // Add Capaian Target personal
  Future<bool> addCapaianTarget(
    int idTarget,
    String deskripsiCapaian,
    int status,
  ) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      
      final id = await db.insert(
        tableCapaian,
        {
          'id_target': idTarget,
          'deskripsi_capaian': deskripsiCapaian,
          'status': status,
          'created_at': now,
          'updated_at': now,
        },
      );
      return id > 0;
    } catch (e) {
      print('Error adding capaian: $e');
      return false;
    }
  }

  // Get Data Target
  Future<List<TargetPersonal>> getTargetPersonal() async {
    return getAllTargets();
  }

  // Get Capaian Target Personal
  Future<List<CapaianTarget>> getCapaianTargetPersonal(int idTarget) async {
    return getCapaianByTargetId(idTarget);
  }

  // Target Personal Methods
  Future<List<TargetPersonal>> getAllTargets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableTargetPersonal);
    return List.generate(maps.length, (i) {
      return TargetPersonal.fromMap(maps[i]);
    });
  }

  Future<List<CapaianTarget>> getCapaianByTargetId(int targetId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableCapaian,
      where: 'id_target = ?',
      whereArgs: [targetId],
    );
    return List.generate(maps.length, (i) {
      return CapaianTarget.fromMap(maps[i]);
    });
  }

  Future<bool> updateCapaianStatus(int capaianId, int newStatus) async {
    try {
      final db = await database;
      await db.update(
        tableCapaian,
        {
          'status': newStatus, 
          'updated_at': DateTime.now().toIso8601String()
        },
        where: 'id = ?',
        whereArgs: [capaianId],
      );
      return true;
    } catch (e) {
      print('Error updating capaian status: $e');
      return false;
    }
  }

  insertCatatan(String teks, String? path) {}
}
