import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uneeds/utils/color.dart';
import 'package:flutter/foundation.dart';
import 'home_page.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Gunakan konfigurasi default tanpa serverClientId
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  User? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _user != null ? HomePage() : _welcomeView());
  }

  Widget _welcomeView() {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 69),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Siap Untuk Menjadi\nLebih Fokus?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: "InterBold", fontSize: 24),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Masuk dengan akun google anda untuk merasakan pengalaman terbaik",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "InterMedium",
                      fontSize: 14,
                      color: fontGrayColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(55, 0, 55, 55),
            child: Image.asset('assets/gambar/login.png'),
          ),
          _isLoading 
            ? CircularProgressIndicator(color: Color(0xFF1F4D70))
            : GestureDetector(
                onTap: () {
                  _handleGoogleSignIn();
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/gambar/google.png",
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Masuk Dengan Google",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // Handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Pastikan keluar dulu dari akun google sebelumnya jika ada
      await _googleSignIn.signOut();
      
      // Debug
      print("Memulai proses Google Sign In");
      
      // Coba dengan metode manual
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("Login dibatalkan oleh pengguna");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print("Berhasil mendapatkan Google user: ${googleUser.email}");
      
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
          
      print("Token ID diperoleh: ${googleAuth.idToken != null ? 'Ya' : 'Tidak'}");
      print("Access Token diperoleh: ${googleAuth.accessToken != null ? 'Ya' : 'Tidak'}");

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      print("Mencoba login ke Firebase dengan credential");
      
      final userCredential = await _auth.signInWithCredential(credential);
      print("Login berhasil dengan user: ${userCredential.user?.email}");
    } catch (error) {
      print("Google Sign-In Error: $error");
      
      // Mencoba dengan metode alternatif
      if (error.toString().contains("ApiException: 10")) {
        try {
          // Coba dengan metode alternatif (sign-in silently atau anonymous)
          print("Mencoba metode login alternatif...");
          
          // Pilihan 1: Login tanpa nama (anonymous)
          final userCredential = await _auth.signInAnonymously();
          print("Login anonymous berhasil dengan user: ${userCredential.user?.uid}");
          
          // Tampilkan alert ke user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login sebagai tamu berhasil. Beberapa fitur mungkin terbatas.")),
          );
          return;
        } catch (secondError) {
          print("Login alternatif gagal: $secondError");
        }
      }
      
      // Tampilkan pesan error yang lebih detil
      String errorMessage = "Gagal masuk: $error";
      if (error.toString().contains("ApiException: 10")) {
        errorMessage = "Gagal verifikasi SHA1 fingerprint. Pastikan fingerprint sudah terdaftar di Firebase Console.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
