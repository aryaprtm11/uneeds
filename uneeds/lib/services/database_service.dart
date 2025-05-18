import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uneeds/models/jadwal.dart';

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
      version: 1,
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
            id_target INTEGER PRIMARY KEY AUTOINCREMENT,
            judul_target VARCHAR NOT NULL,
            deadline VARCHAR NOT NULL,
            createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )''');
        await db.execute('''
          CREATE TABLE $tableCapaian (
            id_capaian INTEGER PRIMARY KEY AUTOINCREMENT,
            id_target INTEGER NOT NULL,
            deskripsi VARCHAR NOT NULL,
            createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (id_target) REFERENCES $tableTargetPersonal(id_target) ON DELETE CASCADE
          )''');
        await db.execute('''
          CREATE TABLE $tableCatatanMateri (
            id_catatan INTEGER PRIMARY KEY AUTOINCREMENT,
            isi_catatan TEXT,
            createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
        ''');
        await db.execute('''
          CREATE TABLE $tableGambarCatatan (
            id_gambar INTEGER PRIMARY KEY AUTOINCREMENT,
            id_catatan INTEGER NOT NULL,
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
      // onUpgrade: (db, oldVersion, newVersion) async {
      //   // Lakukan migrasi skema di sini jika diperlukan
      // },
    );
    return database;
  }

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

  // Mendapatkan data
  Future<List<Jadwal>> getJadwal() async {
    final db = await database;
    final data = await db.query(tableJadwal);
    List<Jadwal> jadwal =
        data
            .map(
              (e) => Jadwal(
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
}
