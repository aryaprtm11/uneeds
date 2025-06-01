# 🧪 Panduan Testing Notifikasi Uneeds

## 🎯 **Cara Kerja Notifikasi Otomatis**

### **1. Notifikasi Target (Deadline)**
- **1 Hari Sebelum:** Notifikasi jam 08:00 pagi
- **Hari Deadline:** Notifikasi jam 07:00 pagi
- **Syarat:** Target harus memiliki tanggal deadline yang valid

### **2. Notifikasi Jadwal Kuliah**
- **Hari Ini:** 30 menit sebelum jadwal dimulai
- **Besok:** 30 menit sebelum jadwal dimulai (untuk info early)
- **Syarat:** Jadwal harus sesuai dengan hari saat ini/besok

### **3. Notifikasi Harian**
- **Waktu:** Setiap hari jam 06:00 pagi
- **Isi:** Reminder untuk cek jadwal dan target hari ini

---

## 📱 **Dimana Notifikasi Muncul**

### **Notifikasi HP**
- Muncul di notification panel Android/iOS
- Ada suara dan getaran (jika diaktifkan)
- Bisa di-tap untuk buka aplikasi

### **Notifikasi Dalam Aplikasi**
- Tersimpan di halaman **Notifikasi** dalam app
- Bisa difilter: Semua, Belum Dibaca, Target, Jadwal
- Status read/unread tracking
- Bisa dihapus individual atau semua

---

## 🔧 **Langkah Testing Manual**

### **Step 1: Persiapan Data**
1. **Tambah Target:**
   - Buat target dengan deadline besok (untuk test 1 hari sebelum)
   - Buat target dengan deadline hari ini (untuk test hari H)
   
2. **Tambah Jadwal:**
   - Buat jadwal kuliah hari ini (30 menit dari sekarang)
   - Buat jadwal kuliah besok (untuk test reminder besok)

### **Step 2: Generate Notifikasi**
1. Buka **Settings** → **Pengaturan Notifikasi**
2. Scroll ke bagian **"Debug & Testing"**
3. Tekan tombol **"Jadwalkan Notifikasi Sekarang"**
4. Cek console/log untuk melihat detail penjadwalan

### **Step 3: Verifikasi Hasil**
1. **Cek Database:** Buka halaman **Notifikasi** di app
2. **Lihat Daftar:** Pastikan notifikasi tersimpan di database
3. **Monitor HP:** Tunggu waktu yang dijadwalkan untuk notif HP
4. **Test Interaction:** Tap notifikasi, mark as read, delete, dll

### **Step 4: Monitoring**
1. **Immediate Check:** 
   - Halaman notifikasi app (langsung terlihat)
   - Notification panel HP (untuk yang terjadwal)
2. **Wait & See:** Tunggu waktu yang dijadwalkan
3. **System Check:** Pastikan DND mode nonaktif

---

## 📊 **Log Debugging**

### **Log yang Harus Muncul:**
```
🔄 Starting smart notification generation...
📊 Found X targets and Y schedules
🗑️ Cleared existing scheduled notifications
🎯 Processing target: [Nama Target] (deadline: [Tanggal])
💾 Saved notification to database with ID: [ID]
✅ Scheduled reminder for target: [Nama] at [Waktu]
💾 Saved notification to database with ID: [ID]
✅ Scheduled deadline notification for: [Nama] at [Waktu]
📅 Processing schedule: [Mata Kuliah] ([Hari] [Jam])
💾 Saved notification to database with ID: [ID]
✅ Scheduled class reminder for: [Mata Kuliah] at [Waktu]
💾 Saved notification to database with ID: [ID]
✅ Scheduled daily reminder at 06:00
🎉 Smart notifications generation completed! Total scheduled: X notifications
```

### **Jika Ada Error:**
```
❌ Error scheduling target notification for [Nama]: [Error]
❌ Error scheduling class notification for [Mata Kuliah]: [Error]
❌ Error generating smart notifications: [Error]
```

---

## 🧪 **Test Cases**

### **Test Case 1: Target Deadline Besok**
**Setup:**
- Buat target dengan deadline besok
- Trigger notification generation

**Expected Result:**
- **Database:** Notifikasi tersimpan di halaman app
- **HP:** Notifikasi terjadwal untuk besok jam 08:00
- **Log:** `💾 Saved notification to database with ID: [ID]`
- **Log:** `✅ Scheduled reminder for target: [Nama] at [Besok 08:00]`

### **Test Case 2: Target Deadline Hari Ini**
**Setup:**
- Buat target dengan deadline hari ini
- Trigger notification generation

**Expected Result:**
- **Database:** Notifikasi tersimpan di halaman app
- **HP:** Notifikasi terjadwal untuk hari ini jam 07:00 (jika masih belum jam 7)
- **Log:** `💾 Saved notification to database with ID: [ID]`
- **Log:** `✅ Scheduled deadline notification for: [Nama] at [Hari ini 07:00]`

### **Test Case 3: Jadwal Kuliah Hari Ini**
**Setup:**
- Buat jadwal kuliah hari ini, 1 jam dari sekarang
- Trigger notification generation

**Expected Result:**
- **Database:** Notifikasi tersimpan di halaman app
- **HP:** Notifikasi terjadwal 30 menit sebelum jadwal
- **Log:** `💾 Saved notification to database with ID: [ID]`
- **Log:** `✅ Scheduled class reminder for: [Mata Kuliah] at [30 menit sebelum]`

### **Test Case 4: Daily Reminder**
**Setup:**
- Trigger notification generation

**Expected Result:**
- **Database:** Notifikasi tersimpan di halaman app
- **HP:** Daily reminder terjadwal jam 06:00 setiap hari
- **Log:** `💾 Saved notification to database with ID: [ID]`
- **Log:** `✅ Scheduled daily reminder at 06:00`

### **Test Case 5: Halaman Notifikasi App**
**Setup:**
- Setelah generate notifikasi, buka halaman notifikasi

**Expected Result:**
- Daftar notifikasi muncul di halaman app
- Tab "Semua" dan "Belum Dibaca" berfungsi
- Filter chips (Target, Jadwal) berfungsi
- Mark as read/delete berfungsi

---

## ⏰ **Testing Real-Time**

### **Quick Test (2-3 Menit):**
1. Buat jadwal kuliah 3 menit dari sekarang
2. Trigger notification generation
3. **Immediate:** Lihat notifikasi di halaman app
4. **Wait:** Tunggu notif HP muncul 30 menit sebelum jadwal

### **Advanced Test (Set Waktu Spesifik):**
Untuk test yang lebih akurat, ubah waktu di kode:
```dart
// Di database_service.dart, ganti:
final reminderTime = todayScheduleTime.subtract(const Duration(minutes: 30));

// Menjadi (untuk test):
final reminderTime = now.add(const Duration(minutes: 1)); // 1 menit dari sekarang
```

---

## 🐛 **Common Issues & Solutions**

### **Issue 1: Tidak Ada Log yang Muncul**
**Penyebab:** Service notifikasi belum initialize atau database error
**Solusi:** Restart aplikasi, cek database connection

### **Issue 2: Notifikasi App Muncul, HP Tidak**
**Penyebab:** 
- DND mode aktif
- Battery optimization
- App background restrictions

**Solusi:** Ikuti panduan troubleshooting HP

### **Issue 3: Notifikasi HP Muncul, App Tidak**
**Penyebab:** Database save gagal
**Solusi:** Cek log error, restart app

### **Issue 4: Error "No targets/schedules found"**
**Penyebab:** Belum ada data target/jadwal
**Solusi:** Tambah data target dan jadwal dulu

### **Issue 5: Waktu Salah**
**Penyebab:** Parsing waktu gagal atau timezone salah
**Solusi:** Cek format waktu di database (HH:mm)

---

## 📝 **Template Test Report**

```
## Test Report - [Tanggal]

### Setup:
- Target: [Jumlah] targets dengan deadline [tanggal]
- Jadwal: [Jumlah] schedules untuk [hari]

### Trigger:
- Waktu trigger: [jam:menit]
- Method: Manual via debug button

### Results:
- Total notifications scheduled: [jumlah]
- Target notifications: [jumlah]
- Schedule notifications: [jumlah]
- Daily reminder: [Ya/Tidak]

### Database Check:
- Notifikasi tersimpan di app: [Ya/Tidak]
- Total notifikasi di halaman app: [jumlah]
- Filter berfungsi: [Ya/Tidak]

### Logs:
[Copy paste log dari console]

### HP Notifications:
- [Waktu] - [Judul] - [Status: Scheduled/Received]

### App Notifications:
- [Judul] - [Status: Visible/Not Visible]
- Mark as read: [Working/Not Working]
- Delete: [Working/Not Working]

### Issues:
[Jika ada masalah]

### Status: [PASS/FAIL]
```

---

## 💡 **Tips Testing**

1. **Selalu cek log console** untuk memastikan penjadwalan berhasil
2. **Cek halaman notifikasi app** untuk memastikan database save berhasil
3. **Test dengan data minimal** (1 target, 1 jadwal)
4. **Gunakan waktu yang dekat** untuk testing immediate
5. **Dokumentasikan hasil** untuk tracking
6. **Test di device berbeda** jika memungkinkan
7. **Restart app** setelah perubahan besar

---

## 🚀 **Production Checklist**

Sebelum release, pastikan:
- [ ] Notifikasi tersimpan di database aplikasi
- [ ] Notifikasi HP berfungsi dengan scheduling
- [ ] Halaman notifikasi app menampilkan semua notifikasi
- [ ] Filter dan search di halaman notifikasi berfungsi
- [ ] Mark as read/unread berfungsi
- [ ] Delete individual dan bulk berfungsi
- [ ] All notification types generate properly
- [ ] Debug button removed/hidden
- [ ] Proper error handling
- [ ] Battery optimization guidance provided
- [ ] User guide documentation complete 