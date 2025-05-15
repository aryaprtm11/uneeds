import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uneeds/utils/color.dart';
import 'package:uneeds/views/schedule_page.dart';
import 'package:uneeds/views/note_page.dart';
import 'package:uneeds/views/target_page.dart';

class HomePage extends StatefulWidget {
  final User? user;
  const HomePage({this.user, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String firstName = "";
  
  @override
  void initState() {
    super.initState();
    user = widget.user ?? FirebaseAuth.instance.currentUser;
    
    // Mendapatkan nama depan user
    if (user != null && user!.displayName != null) {
      firstName = _getFirstName(user!.displayName!);
    } else {
      firstName = "User";
    }
    
    // Debug print untuk memeriksa apakah user sudah terautentikasi
    print("HomePage: User authenticated: ${user != null}");
    if (user != null) {
      print("User email: ${user!.email}");
      print("User name: ${user!.displayName}");
    }
  }
  
  // Fungsi untuk mendapatkan nama depan dari nama lengkap
  String _getFirstName(String fullName) {
    List<String> nameParts = fullName.trim().split(" ");
    return nameParts[0];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Color(0xFFE6F2FD), // Latar belakang biru muda
      body: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 40, 20, 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, $firstName!",
                      style: TextStyle(
                        color: Color(0xFF4A6D8C),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Beranda",
                      style: TextStyle(
                        color: Color(0xFF1F4D70),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF1F4D70),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(Icons.notifications, color: Colors.white),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF1F4D70),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Spacer to push navbar to bottom
          Spacer(),
          
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
                    // Home button (active)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: primaryBlueColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                        size: 30,
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
