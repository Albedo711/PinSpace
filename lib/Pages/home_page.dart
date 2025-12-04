import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/photo_service.dart';
import '../model/photo.dart';
import '../model/user.dart';

// IMPORT HALAMAN LAIN
import 'login_page.dart';
import 'register_page.dart';
// import 'search_page.dart';
import 'upload_page.dart';
// import 'board_page.dart';
// import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Photo> photos = [];
  bool loading = true;
  bool error = false;
  bool isLoggedIn = false;

  UserModel? userModel; // TAMBAHAN MODEL USER

  int currentIndex = 0;

  final PhotoService _photoService = PhotoService();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    fetchPhotos();
  }

  // Cek login + load user
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (loggedIn) {
      setState(() {
        isLoggedIn = true;
        userModel = UserModel(
          id: prefs.getInt("user_id")!,
          name: prefs.getString("user_name") ?? '',
          email: prefs.getString("user_email") ?? '',
          avatar: prefs.getString("user_avatar"),
          bio: prefs.getString("user_bio"),
        );
      });
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      isLoggedIn = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logout berhasil")),
    );
  }

  // Fetch photos
  Future<void> fetchPhotos() async {
    try {
      final result = await _photoService.getPhotos();
      setState(() {
        photos = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  // BOTTOM NAVIGATION HANDLER
  void onTabTapped(int index) {
  // Update UI index
  setState(() => currentIndex = index);

  // ===================================================
  // CEK LOGIN — jika belum login, tampilkan peringatan
  // ===================================================
  if (!isLoggedIn && index != 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Anda belum login"),
        duration: Duration(seconds: 2),
      ),
    );
    return; // stop navigasi
  }

  // ===================================================
  // NAVIGASI JIKA LOGIN
  // ===================================================
  if (index == 0) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  } else if (index == 1) {
    // TODO: Search Page
  } else if (index == 2) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const UploadPage()),
    );
  } else if (index == 3) {
    // TODO: Board Page
  } else if (index == 4) {
    // TODO: Profile Page
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1523),

      // ---------------------------------------------------
      //                      APP BAR
      // ---------------------------------------------------
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2332),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "PinSpace",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            // Jika sudah login → tampilkan upload + avatar
            if (isLoggedIn)
              Row(
                children: [

                  /// AVATAR + DROPDOWN
                  PopupMenuButton<String>(
  offset: const Offset(0, 45),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  onSelected: (value) {
    if (value == "profile") {
      // TODO: buka halaman profile
    } else if (value == "logout") {
      logout();
    }
  },
  itemBuilder: (context) => const [
    PopupMenuItem(
      value: "profile",
      child: Text("Profile"),
    ),
    PopupMenuItem(
      value: "dashboard",
      child: Text("Dashboard"),
    ),
    PopupMenuItem(
      value: "logout",
      child: Text("Logout"),
    ),
  ],

  // ------------------------------
  //      AVATAR (with fallback)
  // ------------------------------
  child: Container(
    width: 34,
    height: 34,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
    ),
    child: ClipOval(
      child: (userModel?.avatar == null || userModel!.avatar!.isEmpty)
          ? const Icon(
              Icons.person,
              color: Colors.black87,
              size: 26,
            )
          : Image.network(
              "http://127.0.0.1:8000/${userModel!.avatar}",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  color: Colors.black87,
                  size: 26,
                );
              },
            ),
    ),
  ),
)

                ],
              )
            else
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      ).then((_) => checkLoginStatus());
                    },
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ).then((_) => checkLoginStatus());
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),

      // ---------------------------------------------------
      //                      BODY
      // ---------------------------------------------------
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error
              ? const Center(
                  child: Text(
                    "You're not logged in",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : photos.isEmpty
                  ? const Center(
                      child: Text(
                        "You are not logged in",
                        style: TextStyle(color: Colors.white60, fontSize: 18),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount;
                          double screenWidth = constraints.maxWidth;

                          if (screenWidth >= 1200) {
                            crossAxisCount = 5;
                          } else if (screenWidth >= 992) {
                            crossAxisCount = 4;
                          } else if (screenWidth >= 768) {
                            crossAxisCount = 3;
                          } else {
                            crossAxisCount = 2;
                          }

                          double spacing = 10;
                          double width = (screenWidth -
                                  (crossAxisCount - 1) * spacing) /
                              crossAxisCount;
                          double height = width * 1.2;

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: width / height,
                              crossAxisSpacing: spacing,
                              mainAxisSpacing: spacing,
                            ),
                            itemCount: photos.length,
                            itemBuilder: (context, index) {
                              final item = photos[index];
                              final String imagePath =
                                  "http://127.0.0.1:8000/${item.imagePath}";

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  imagePath,
                                  width: width,
                                  height: height,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

      // ---------------------------------------------------
      //         BOTTOM NAVIGATION BAR (NAVBAR BAWAH)
      // ---------------------------------------------------
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A2332),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: currentIndex,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 32),
            label: "Upload",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: "Board",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
