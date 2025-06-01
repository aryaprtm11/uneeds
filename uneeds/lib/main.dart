import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import file konfigurasi Firebase Anda
import 'firebase_options.dart';

// Import halaman loading screen
import 'package:uneeds/views/loading_screen.dart';

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
      title: 'Uneeds - Manage Your Academic Life',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F4D70)),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      // Langsung menampilkan LoadingScreen
      home: const LoadingScreen(),
    );
  }
}
