import 'package:flutter/material.dart';
import 'package:uneeds/utils/color.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(55, 0, 55, 78),
            child: Image.asset('assets/gambar/login.png'),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                // print("lanjut");
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 13.5),
                decoration: BoxDecoration(
                  color: blueColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Masuk",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "InterSemiBold",
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
