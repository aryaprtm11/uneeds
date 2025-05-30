import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import file konfigurasi Firebase Anda
import 'firebase_options.dart';

// Import halaman-halaman Anda
import 'package:uneeds/views/onboarding.dart';
import 'package:uneeds/views/home_page.dart';

// Import service notifikasi
import 'package:uneeds/services/local_notification_service.dart';
import 'package:uneeds/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  
  // Initialize notification service
  print('🚀 Initializing notification service...');
  try {
    await LocalNotificationService().initialize();
    print('✅ Notification service initialized successfully');
    
    // Schedule smart notifications
    print('📅 Scheduling smart notifications...');
    await DatabaseService.instance.generateSmartNotifications();
    print('✅ Smart notifications scheduled successfully');
  } catch (e) {
    print('❌ Error initializing notification service: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome to Uneeds!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Tampilkan loading saat cek status login
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Tampilkan error jika terjadi error
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text('Terjadi kesalahan. Silakan coba lagi.'),
              ),
            );
          }

          // Jika user sudah login, tampilkan HomeView
          if (snapshot.hasData) {
            return const HomePage();
          }

          // Jika user belum login, tampilkan OnboardingView
          return const OnboardingView();
        },
      ),
    );
  }
}
