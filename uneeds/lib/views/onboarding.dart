import 'package:flutter/material.dart';
import 'package:uneeds/utils/color.dart';

List onboardingData = [
  {
    "image": "assets/gambar/welcome-1.png",
    "title": "Selamat Datang di UNEEDS",
    "deskripsi":
        "UNEEDS membantumu mencatat ide, mengelola tugas, dan menyusun hidup dengan rapi — semuanya dalam satu tempat.",
  },
  {
    "image": "assets/gambar/welcome-2.png",
    "title": "Fleksibel. Personal. Terstruktur.",
    "deskripsi":
        "Buat halaman sesuai kebutuhanmu: catatan, to-do list, proyek kerja, hingga jurnal harian. Semua bisa disesuaikan.",
  },
  {
    "image": "assets/gambar/welcome-3.png",
    "title": "Kolaborasi Tanpa Batas",
    "deskripsi":
        "Undang tim atau teman, berbagi ide, dan bekerjalah bersama secara real-time. UNEEDS bikin kerja jadi lebih menyatu.",
  },
];

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: onboardingData.length,
              itemBuilder: (_, i) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Image.asset(onboardingData[i]["image"]),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              onboardingData[i]["title"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "InterBold",
                                fontSize: 24,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              onboardingData[i]["deskripsi"],
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
                  ],
                );
              },
            ),
          ),

          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Wrap(
                  spacing: 6,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: blueColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 8,
                      width: 20,
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: fontGrayColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 8,
                      width: 8,
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: fontGrayColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 8,
                      width: 8,
                    ),
                  ],
                ),
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
                      "Lanjut",
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

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    // print("lewati");
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 13.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Lewati",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "InterSemiBold",
                        fontSize: 14,
                        color: blueColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
