import 'package:flutter/material.dart';
import 'package:uneeds/utils/color.dart';
import 'package:uneeds/views/home_page.dart';
import 'package:uneeds/views/schedule_page.dart';
import 'package:uneeds/views/note_page.dart';

class TargetPage extends StatelessWidget {
  const TargetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Color(0xFFE6F2FD),
      body: Stack(
        children: [
          // Konten halaman Target
          Center(
            child: Text(
              'Halaman Target',
              style: TextStyle(
                fontSize: 24,
                color: primaryBlueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Posisi navbar di bagian bawah
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                // Navbar dan tombol plus
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Container navbar utama
                    Container(
                      width: screenWidth * 0.65,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Home button
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.home_rounded,
                                color: primaryBlueColor,
                                size: 30,
                              ),
                            ),
                          ),
                          
                          // Calendar button
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => SchedulePage(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: primaryBlueColor,
                              size: 30,
                            ),
                          ),
                          
                          // List button
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => NotePage(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            child: Icon(
                              Icons.view_list_rounded,
                              color: primaryBlueColor,
                              size: 30,
                            ),
                          ),
                          
                          // Molecule/Api button (active)
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: primaryBlueColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.api_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Plus button (diluar navbar)
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: primaryBlueColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 55),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 