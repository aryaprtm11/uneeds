import 'package:flutter/material.dart';
import 'package:uneeds/utils/color.dart';
import 'package:uneeds/views/home_page.dart';
import 'package:uneeds/views/schedule_page.dart';
import 'package:uneeds/views/target_page.dart';

class NotePage extends StatelessWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Color(0xFFE6F2FD),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
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
                    
                    // List button (active)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: primaryBlueColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.view_list_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    
                    // Molecule/Api button
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => TargetPage(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Icon(
                        Icons.api_rounded,
                        color: primaryBlueColor,
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
          
          SizedBox(height: 25),
        ],
      ),
    );
  }
} 