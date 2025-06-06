import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'; // Pastikan ini diimpor

// Models
import 'package:uneeds/models/jadwal.dart'; // Model Anda yang lain
import 'package:uneeds/models/note_model.dart'; // Model Note kita
import 'package:uneeds/models/target.dart'; // Model Anda yang lain
import 'package:uneeds/models/notification.dart'; // Model Notification baru

// Services
import 'package:uneeds/services/local_notification_service.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._constructor();
  static final LocalNotificationService _localNotificationService = LocalNotificationService();

  DatabaseService._constructor();

  // Nama Tabel
  static const String tableJadwal = 'jadwal';
  static const String tableTargetPersonal = 'target_personal';
  static const String tableCapaian = 'capaian';
  static const String tableCatatanMateri =
      'catatan_materi'; // Tabel untuk teks catatan
  static const String tableGambarCatatan =
      'gambar_catatan'; // Tabel untuk path gambar catatan
  static const String tableUser = 'user';
  static const String tableNotifications = 'notifications'; // Tabel notifikasi baru

  // Kolom Tabel Jadwal (Tidak diubah, tetap seperti milik Anda)
  static const String columnIdJadwal = 'id_jadwal';
  static const String columnMatkul = 'matkul';
  static const String columnDosen = 'dosen';
  static const String columnHari = 'hari';
  static const String columnRuangan = 'ruangan';
  static const String columnWaktuMulai = 'waktu_mulai';
  static const String columnWaktuSelesai = 'waktu_selesai';
  static const String columnKategori = 'kategori';
  static const String columnCreatedAtJadwal =
      'createdAt'; // Mengganti createdAt agar lebih spesifik

  // Kolom tabel catatan_materi (SESUAIKAN DENGAN SCHEMA ANDA)
  static const String columnIdCatatan =
      'id_catatan'; // PRIMARY KEY di catatan_materi
  static const String columnJudulCatatan = 'judul_catatan';
  static const String columnIsiCatatan = 'isi_catatan';
  static const String columnWaktuCatatan =
      'waktu_catatan'; // Sesuai schema Anda

  // Kolom tabel gambar_catatan (SESUAIKAN DENGAN SCHEMA ANDA)
  static const String columnIdGambar =
      'id_gambar'; // PRIMARY KEY di gambar_catatan
  // 'id_catatan' sudah ada sebagai foreign key
  static const String columnPathGambar = 'gambar'; // Path ke file gambar
  static const String columnCreatedAtGambar =
      'createdAt'; // Mengganti createdAt agar lebih spesifik

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
      version: 3, // Upgrade version untuk tabel notifikasi
      onCreate: (db, version) async {
        // Tabel Jadwal
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
            $columnCreatedAtJadwal TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
          )''');
        // Tabel Target Personal (Sesuai kode Anda)
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
        // Tabel Capaian (Sesuai kode Anda)
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
        // Tabel Catatan Materi (SESUAI SCHEMA ANDA)
        await db.execute('''
          CREATE TABLE $tableCatatanMateri (
            $columnIdCatatan INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnJudulCatatan TEXT,
            $columnIsiCatatan TEXT,
            $columnWaktuCatatan TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
          )
        ''');
        // Tabel Gambar Catatan (SESUAI SCHEMA ANDA)
        await db.execute('''
          CREATE TABLE $tableGambarCatatan (
            $columnIdGambar INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnIdCatatan INTEGER NOT NULL, 
            $columnPathGambar TEXT NOT NULL, 
            $columnCreatedAtGambar TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY ($columnIdCatatan) REFERENCES $tableCatatanMateri($columnIdCatatan) ON DELETE CASCADE
          )''');
        // Tabel User (Sesuai kode Anda)
        await db.execute('''
          CREATE TABLE $tableUser (
            id_user VARCHAR PRIMARY KEY NOT NULL,
            email VARCHAR NOT NULL,
            username VARCHAR NOT NULL
          )''');
        // Tabel Notifications (BARU)
        await db.execute('''
          CREATE TABLE $tableNotifications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title VARCHAR NOT NULL,
            subtitle VARCHAR NOT NULL,
            description TEXT NOT NULL,
            type VARCHAR NOT NULL,
            related_id INTEGER,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            is_read INTEGER NOT NULL DEFAULT 0,
            priority VARCHAR NOT NULL DEFAULT 'medium'
          )''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Logika onUpgrade Anda tetap di sini
        if (oldVersion < 2) {
          // Drop tabel lama untuk target dan capaian jika ada perubahan skema
          await db.execute('DROP TABLE IF EXISTS $tableTargetPersonal');
          await db.execute('DROP TABLE IF EXISTS $tableCapaian');

          // Buat tabel baru untuk target dan capaian (sesuai kode Anda)
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
        
        if (oldVersion < 3) {
          // Tambah tabel notifications jika upgrade dari versi 2
          await db.execute('''
            CREATE TABLE $tableNotifications (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title VARCHAR NOT NULL,
              subtitle VARCHAR NOT NULL,
              description TEXT NOT NULL,
              type VARCHAR NOT NULL,
              related_id INTEGER,
              created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
              is_read INTEGER NOT NULL DEFAULT 0,
              priority VARCHAR NOT NULL DEFAULT 'medium'
            )''');
        }
      },
    );
    return database;
  }

  /* --- Controller Notifikasi --- */
  
  Future<int> addNotification(NotificationModel notification) async {
    final db = await database;
    final id = await db.insert(tableNotifications, notification.toMap());
    
    // Tampilkan notifikasi HP
    final notificationWithId = notification.copyWith(id: id);
    await _localNotificationService.showNotificationFromModel(notificationWithId);
    
    return id;
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotifications,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return NotificationModel.fromMap(maps[i]);
    });
  }

  Future<List<NotificationModel>> getUnreadNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotifications,
      where: 'is_read = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) {
      return NotificationModel.fromMap(maps[i]);
    });
  }

  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final db = await database;
      await db.update(
        tableNotifications,
        {'is_read': 1},
        where: 'id = ?',
        whereArgs: [notificationId],
      );
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool> markAllNotificationsAsRead() async {
    try {
      final db = await database;
      await db.update(
        tableNotifications,
        {'is_read': 1},
        where: 'is_read = ?',
        whereArgs: [0],
      );
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(int notificationId) async {
    try {
      final db = await database;
      await db.delete(
        tableNotifications,
        where: 'id = ?',
        whereArgs: [notificationId],
      );
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  Future<bool> deleteAllNotifications() async {
    try {
      final db = await database;
      await db.delete(tableNotifications);
      return true;
    } catch (e) {
      print('Error deleting all notifications: $e');
      return false;
    }
  }

  Future<void> generateSmartNotifications() async {
    try {
      print('🔄 Starting smart notification generation...');
      
      final targets = await getAllTargets();
      final schedules = await getJadwal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      print('📊 Found ${targets.length} targets and ${schedules.length} schedules');

      // Clear existing scheduled notifications
      await _localNotificationService.cancelAllNotifications();
      print('🗑️ Cleared existing scheduled notifications');

      int scheduledCount = 0;

      // Schedule notifications untuk setiap target (ONLY ONCE PER TARGET)
      for (var target in targets) {
        try {
          final targetDate = DateTime.parse(target.tanggalTarget);
          final targetDateOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);
          
          print('🎯 Processing target: ${target.namaTarget} (deadline: ${targetDate.toString()})');
          
          // Cek apakah sudah ada notifikasi untuk target ini hari ini
          final existingTargetNotifications = await _getExistingNotificationsForTarget(target.id ?? 0);
          if (existingTargetNotifications.isNotEmpty) {
            print('⏭️ Skipping target ${target.namaTarget} - notification already exists today');
            continue;
          }
          
          // Schedule notification 1 hari sebelum deadline (jam 8 pagi) - SEKALI SAJA
          final oneDayBefore = targetDateOnly.subtract(const Duration(days: 1));
          if (oneDayBefore.isAfter(today) || (oneDayBefore.isAtSameMomentAs(today) && now.hour < 8)) {
            final notificationTime = DateTime(oneDayBefore.year, oneDayBefore.month, oneDayBefore.day, 8, 0);
            
            if (notificationTime.isAfter(now)) {
              // Save to database first
              final notification = NotificationModel(
                title: 'Deadline Besok!',
                subtitle: 'Target akan berakhir besok',
                description: 'Target "${target.namaTarget}" akan berakhir besok. Segera selesaikan!',
                type: 'target',
                relatedId: target.id,
                priority: 'high',
                createdAt: now,
                isRead: false,
              );
              
              final notificationId = await addNotificationOnly(notification);
              
              // Schedule HP notification SEKALI SAJA (bukan recurring)
              await _localNotificationService.scheduleNotification(
                id: notificationId,
                title: notification.title,
                body: notification.description,
                scheduledDate: notificationTime,
                payload: 'target:${target.id}',
                priority: NotificationPriority.high,
              );
              
              scheduledCount++;
              print('✅ Scheduled ONE-TIME reminder for target: ${target.namaTarget} at $notificationTime');
            }
          }
          
          // Schedule notification pada hari deadline (jam 7 pagi) - SEKALI SAJA
          if (targetDateOnly.isAfter(today) || (targetDateOnly.isAtSameMomentAs(today) && now.hour < 7)) {
            final deadlineNotificationTime = DateTime(targetDateOnly.year, targetDateOnly.month, targetDateOnly.day, 7, 0);
            
            if (deadlineNotificationTime.isAfter(now)) {
              // Save to database first
              final notification = NotificationModel(
                title: 'Deadline Hari Ini!',
                subtitle: 'Target harus diselesaikan hari ini',
                description: 'Target "${target.namaTarget}" harus diselesaikan hari ini. Jangan sampai terlewat!',
                type: 'target',
                relatedId: target.id,
                priority: 'high',
                createdAt: now,
                isRead: false,
              );
              
              final notificationId = await addNotificationOnly(notification);
              
              // Schedule HP notification SEKALI SAJA
              await _localNotificationService.scheduleNotification(
                id: notificationId,
                title: notification.title,
                body: notification.description,
                scheduledDate: deadlineNotificationTime,
                payload: 'target:${target.id}',
                priority: NotificationPriority.high,
              );
              
              scheduledCount++;
              print('✅ Scheduled ONE-TIME deadline notification for: ${target.namaTarget} at $deadlineNotificationTime');
            }
          }

        } catch (e) {
          print('❌ Error scheduling target notification for ${target.namaTarget}: $e');
        }
      }

      // Schedule notifications untuk jadwal kuliah hari ini dan besok (ONLY ONCE PER SCHEDULE)
      for (var schedule in schedules) {
        try {
          final scheduleDay = schedule.hari.toLowerCase();
          final scheduleStartTime = _parseTime(schedule.waktuMulai);
          
          print('📅 Processing schedule: ${schedule.matkul} (${schedule.hari} ${schedule.waktuMulai}-${schedule.waktuSelesai})');
          
          // Cek apakah sudah ada notifikasi untuk jadwal ini hari ini
          final existingScheduleNotifications = await _getExistingNotificationsForSchedule(schedule.id ?? 0);
          if (existingScheduleNotifications.isNotEmpty) {
            print('⏭️ Skipping schedule ${schedule.matkul} - notification already exists today');
            continue;
          }
          
          // Check for today's schedule
          if (_getDayString(now.weekday).toLowerCase() == scheduleDay) {
            final todayScheduleTime = DateTime(today.year, today.month, today.day, scheduleStartTime.hour, scheduleStartTime.minute);
            final reminderTime = todayScheduleTime.subtract(const Duration(minutes: 30)); // 30 menit sebelum
            
            if (reminderTime.isAfter(now)) {
              // Save to database first
              final notification = NotificationModel(
                title: 'Kuliah Dimulai 30 Menit Lagi',
                subtitle: '${schedule.matkul} - ${schedule.ruangan}',
                description: '${schedule.matkul} akan dimulai jam ${schedule.waktuMulai} di ${schedule.ruangan}',
                type: 'schedule',
                relatedId: schedule.id,
                priority: 'high',
                createdAt: now,
                isRead: false,
              );
              
              final notificationId = await addNotificationOnly(notification);
              
              // Schedule HP notification SEKALI SAJA
              await _localNotificationService.scheduleNotification(
                id: notificationId,
                title: notification.title,
                body: notification.description,
                scheduledDate: reminderTime,
                payload: 'schedule:${schedule.id}',
                priority: NotificationPriority.high,
              );
              
              scheduledCount++;
              print('✅ Scheduled ONE-TIME class reminder for: ${schedule.matkul} at $reminderTime');
            }
          }

        } catch (e) {
          print('❌ Error scheduling class notification for ${schedule.matkul}: $e');
        }
      }

      // HAPUS daily reminder yang berulang - cukup buat notifikasi info sekali saja
      try {
        // Cek apakah sudah ada daily reminder hari ini
        final existingDailyReminder = await _getExistingDailyReminder();
        
        if (existingDailyReminder.isEmpty) {
          // Save ONE-TIME daily info notification to database (bukan recurring)
          final dailyNotification = NotificationModel(
            title: 'Jadwal Hari Ini 📅',
            subtitle: 'Info jadwal dan target',
            description: 'Anda memiliki ${schedules.length} jadwal dan ${targets.length} target. Semangat hari ini!',
            type: 'daily',
            relatedId: null,
            priority: 'medium',
            createdAt: now,
            isRead: false,
          );
          
          await addNotificationOnly(dailyNotification);
          scheduledCount++;
          print('✅ Added ONE-TIME daily info notification (no recurring)');
        } else {
          print('⏭️ Daily reminder already exists today - skipping');
        }
      } catch (e) {
        print('❌ Error creating daily info: $e');
      }

      print('🎉 Smart notifications generation completed! Total scheduled: $scheduledCount notifications (NO SPAM!)');

    } catch (e) {
      print('❌ Error generating smart notifications: $e');
    }
  }

  // Helper method untuk cek existing notifications untuk target
  Future<List<NotificationModel>> _getExistingNotificationsForTarget(int targetId) async {
    final db = await database;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotifications,
      where: 'type = ? AND related_id = ? AND created_at >= ?',
      whereArgs: ['target', targetId, todayStart.toIso8601String()],
    );
    
    return List.generate(maps.length, (i) => NotificationModel.fromMap(maps[i]));
  }

  // Helper method untuk cek existing notifications untuk schedule
  Future<List<NotificationModel>> _getExistingNotificationsForSchedule(int scheduleId) async {
    final db = await database;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotifications,
      where: 'type = ? AND related_id = ? AND created_at >= ?',
      whereArgs: ['schedule', scheduleId, todayStart.toIso8601String()],
    );
    
    return List.generate(maps.length, (i) => NotificationModel.fromMap(maps[i]));
  }

  // Helper method untuk cek existing daily reminder hari ini
  Future<List<NotificationModel>> _getExistingDailyReminder() async {
    final db = await database;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotifications,
      where: 'type = ? AND created_at >= ?',
      whereArgs: ['daily', todayStart.toIso8601String()],
    );
    
    return List.generate(maps.length, (i) => NotificationModel.fromMap(maps[i]));
  }

  String _getDayString(int weekday) {
    switch (weekday) {
      case 1: return 'Senin';
      case 2: return 'Selasa';
      case 3: return 'Rabu';
      case 4: return 'Kamis';
      case 5: return 'Jumat';
      case 6: return 'Sabtu';
      case 7: return 'Minggu';
      default: return 'Senin';
    }
  }

  /* --- Controller Catatan Materi --- */

  Future<int> addNote(Note note) async {
    final db = await database;
    // Masukkan data teks catatan
    Map<String, dynamic> noteData = {
      columnJudulCatatan: note.title,
      columnIsiCatatan: note.content,
      columnWaktuCatatan: note.createdTime.toIso8601String(),
    };

    int noteId = await db.insert(tableCatatanMateri, noteData);

    // Jika ada gambar, masukkan ke tabel gambar_catatan
    if (note.imagePath != null && note.imagePath!.isNotEmpty) {
      Map<String, dynamic> imageData = {
        columnIdCatatan: noteId, // Foreign key
        columnPathGambar: note.imagePath!,
        // createdAtGambar akan default CURRENT_TIMESTAMP
      };
      await db.insert(tableGambarCatatan, imageData);
    }
    return noteId;
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    // Query semua catatan dari tabel teks
    final List<Map<String, dynamic>> noteMaps = await db.query(
      tableCatatanMateri,
      orderBy: "$columnWaktuCatatan DESC", // Urutkan dari terbaru
    );

    List<Note> notes = [];
    for (var noteMap in noteMaps) {
      int noteId = noteMap[columnIdCatatan] as int;
      String? imagePath;

      // Ambil gambar pertama yang terkait dengan noteId ini
      final List<Map<String, dynamic>> imageMaps = await db.query(
        tableGambarCatatan,
        where: '$columnIdCatatan = ?',
        whereArgs: [noteId],
        limit: 1, // Ambil hanya satu gambar
      );

      if (imageMaps.isNotEmpty) {
        imagePath = imageMaps.first[columnPathGambar] as String?;
      }

      notes.add(
        Note(
          id: noteId,
          title: noteMap[columnJudulCatatan] as String,
          content: noteMap[columnIsiCatatan] as String,
          createdTime: DateTime.parse(noteMap[columnWaktuCatatan] as String),
          imagePath: imagePath,
        ),
      );
    }
    return notes;
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    int updatedRows = await db.update(
      tableCatatanMateri,
      {
        columnJudulCatatan: note.title,
        columnIsiCatatan: note.content,
        columnWaktuCatatan:
            note.createdTime.toIso8601String(), // Atau waktu update
      },
      where: '$columnIdCatatan = ?',
      whereArgs: [note.id],
    );

    // Hapus gambar lama yang terkait dengan catatan ini
    await db.delete(
      tableGambarCatatan,
      where: '$columnIdCatatan = ?',
      whereArgs: [note.id],
    );

    // Jika ada gambar baru, masukkan
    if (note.imagePath != null && note.imagePath!.isNotEmpty) {
      await db.insert(tableGambarCatatan, {
        columnIdCatatan: note.id,
        columnPathGambar: note.imagePath!,
      });
    }
    return updatedRows;
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    // Karena ada ON DELETE CASCADE, menghapus dari tableCatatanMateri
    // juga akan menghapus entri terkait di tableGambarCatatan.
    return await db.delete(
      tableCatatanMateri,
      where: '$columnIdCatatan = ?',
      whereArgs: [id],
    );
  }

  /* --- Controller Jadwal (TETAP SEPERTI MILIK ANDA) --- */
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

  Future<List<Jadwal>> getJadwal() async {
    final db = await database;
    final data = await db.query(tableJadwal);
    List<Jadwal> jadwal =
        data
            .map(
              (e) => Jadwal(
                // Asumsi Anda punya model Jadwal
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

  /* --- Controller Target Personal --- */
  Future<bool> addTargetPersonal(
    String namaTarget,
    String jenisTarget,
    String tanggalTarget,
    String waktuTarget,
  ) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      final id = await db.insert(tableTargetPersonal, {
        'nama_target': namaTarget,
        'jenis_target': jenisTarget,
        'tanggal_target': tanggalTarget,
        'waktu_target': waktuTarget,
        'created_at': now,
        'updated_at': now,
      });
      return id > 0;
    } catch (e) {
      print('Error adding target: $e');
      return false;
    }
  }

  Future<bool> addCapaianTarget(
    int idTarget,
    String deskripsiCapaian,
    int status,
  ) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      final id = await db.insert(tableCapaian, {
        'id_target': idTarget,
        'deskripsi_capaian': deskripsiCapaian,
        'status': status,
        'created_at': now,
        'updated_at': now,
      });
      return id > 0;
    } catch (e) {
      print('Error adding capaian: $e');
      return false;
    }
  }

  Future<List<TargetPersonal>> getTargetPersonal() async {
    return getAllTargets();
  }

  Future<List<CapaianTarget>> getCapaianTargetPersonal(int idTarget) async {
    return getCapaianByTargetId(idTarget);
  }

  Future<List<TargetPersonal>> getAllTargets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableTargetPersonal);
    return List.generate(maps.length, (i) {
      return TargetPersonal.fromMap(
        maps[i],
      ); // Asumsi Anda punya model TargetPersonal
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
      return CapaianTarget.fromMap(
        maps[i],
      ); // Asumsi Anda punya model CapaianTarget
    });
  }

  Future<bool> updateCapaianStatus(int capaianId, int newStatus) async {
    try {
      final db = await database;
      await db.update(
        tableCapaian,
        {'status': newStatus, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [capaianId],
      );
      return true;
    } catch (e) {
      print('Error updating capaian status: $e');
      return false;
    }
  }

  Future<bool> updateTargetPersonal(
    int id,
    String namaTarget,
    String jenisTarget,
    String tanggalTarget,
    String waktuTarget,
  ) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      final count = await db.update(
        tableTargetPersonal,
        {
          'nama_target': namaTarget,
          'jenis_target': jenisTarget,
          'tanggal_target': tanggalTarget,
          'waktu_target': waktuTarget,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      print('Error updating target: $e');
      return false;
    }
  }

  Future<bool> deleteCapaian(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        tableCapaian,
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      print('Error deleting capaian: $e');
      return false;
    }
  }

  Future<bool> deleteTargetPersonal(int id) async {
    try {
      final db = await database;
      
      // Hapus semua capaian yang terkait dengan target ini
      await db.delete(
        tableCapaian,
        where: 'id_target = ?',
        whereArgs: [id],
      );
      
      // Hapus target personal
      final count = await db.delete(
        tableTargetPersonal,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      return count > 0;
    } catch (e) {
      print('Error deleting target personal: $e');
      return false;
    }
  }

  // Helper method untuk add notification tanpa trigger HP notification (sudah dijadwalkan)
  Future<int> addNotificationOnly(NotificationModel notification) async {
    final db = await database;
    final id = await db.insert(tableNotifications, notification.toMap());
    print('💾 Saved notification to database with ID: $id');
    return id;
  }
  
  // Helper method untuk parse waktu string ke DateTime time components
  DateTime _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(2024, 1, 1, hour, minute); // Dummy date, we only care about time
    } catch (e) {
      print('Error parsing time $timeString: $e');
      return DateTime(2024, 1, 1, 8, 0); // Default to 8:00 AM
    }
  }
}
