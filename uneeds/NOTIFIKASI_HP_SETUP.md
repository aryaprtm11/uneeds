# 📱 Panduan Mengaktifkan Notifikasi HP di Uneeds

## 🚀 Langkah-langkah Setup

### 1. **Tambahkan Dependencies di `pubspec.yaml`**
```yaml
dependencies:
  flutter_local_notifications: ^16.3.2
  permission_handler: ^11.1.0
```

### 2. **Setup Android Permissions**
Buka file `android/app/src/main/AndroidManifest.xml` dan tambahkan permissions berikut:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

Dalam tag `<application>`, tambahkan:
```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

### 3. **Setup iOS Permissions**
Buka file `ios/Runner/Info.plist` dan tambahkan:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>background-processing</string>
    <string>background-fetch</string>
</array>
```

### 4. **Aktifkan Implementation**
Buka file `lib/services/local_notification_service.dart`:

1. **Uncomment** semua kode yang ada dalam blok komentar `/* ... */`
2. **Hapus** implementasi placeholder
3. **Import** packages yang dibutuhkan:
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
```

### 5. **Initialize di Main App**
Di file `lib/main.dart`, tambahkan inisialisasi:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local notifications
  await LocalNotificationService().initialize();
  
  runApp(MyApp());
}
```

## 🎯 Fitur Notifikasi yang Tersedia

### **Smart Notifications** 🧠
- ✅ **Target Deadline Today** (Prioritas TINGGI)
- ✅ **Target Deadline Tomorrow** (Prioritas MEDIUM)  
- ✅ **Daily Schedule Reminder** (Prioritas MEDIUM)

### **Notification Management** 📋
- ✅ **Mark as Read/Unread**
- ✅ **Delete Individual Notifications**
- ✅ **Delete All Notifications**
- ✅ **Filter by Type** (Target/Schedule/System)
- ✅ **Priority-based Display**

### **Visual Indicators** 🎨
- ✅ **Badge Counter** pada icon notifikasi
- ✅ **Priority Labels** (Urgent untuk prioritas tinggi)
- ✅ **Color-coded Types**:
  - 🎯 Target: Hijau (`#2E7D32`)
  - 📅 Jadwal: Biru (`primaryBlueColor`)
  - 🔔 System: Biru Gelap (`#2B4865`)

## 🔧 Testing

Setelah setup selesai:

1. **Generate notifikasi baru** dengan membuat target deadline hari ini/besok
2. **Lihat badge counter** di icon notifikasi home page
3. **Tap notifikasi HP** untuk membuka app
4. **Test filter dan management** di halaman notifikasi

## 📱 Notification Channels

### Android
- **Channel ID**: `uneeds_channel`
- **Channel Name**: `Uneeds Notifications`
- **Importance**: High/Default/Low based on priority

### iOS
- **Sound**: Enabled
- **Badge**: Enabled  
- **Alert**: Enabled

## 🚨 Troubleshooting

### Permission Issues
```dart
// Check notification permission status
final status = await Permission.notification.status;
if (status.isDenied) {
  await Permission.notification.request();
}
```

### Android 13+ Considerations
- POST_NOTIFICATIONS permission diperlukan untuk Android 13+
- User harus mengizinkan permission secara manual

### Testing Mode
Saat ini sudah ada **placeholder implementation** yang akan print notifikasi ke console untuk testing tanpa dependencies.

---

**📝 Catatan**: Setelah mengaktifkan notifikasi HP, restart aplikasi untuk memastikan semua konfigurasi berjalan dengan baik. 