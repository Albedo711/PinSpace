import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Photos/detail_page.dart';
import '../Services/photo_service.dart';
import '../model/photo.dart';
import '../model/user.dart';
import '../Services/user_service.dart';
import 'Board/my_board_page.dart';
// IMPORT HALAMAN LAIN
import 'Auth/login_page.dart';
import 'Auth/register_page.dart';
import 'search_page.dart';
import 'Photos/upload_page.dart';
import 'Profile/profile_page.dart';
import 'save_page.dart';

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
  final UserService _userService = UserService();
  UserModel? userModel;

  int currentIndex = 0;

  final PhotoService _photoService = PhotoService();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    fetchPhotos();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final profile = await _userService.getProfile();
      setState(() {
        userModel = profile;
      });
    } catch (e) {
      print("Gagal load user: $e");
    }
  }

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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      isLoggedIn = false;
      photos = [];
      currentIndex = 0; // Reset ke home setelah logout
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logout berhasil")),
    );
  }

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

  // INI YANG DIUBAH - Cuma setState, tidak ada Navigator
  void onTabTapped(int index) {
    if (!isLoggedIn && index != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Anda belum login"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1523),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1A2332),
        elevation: 4,
        shadowColor: Colors.black45,
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                "PinSpace",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            if (isLoggedIn)
              Row(
  children: [
    PopupMenuButton<String>(
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        if (value == "profile") {
          setState(() {
            currentIndex = 4;
          });
        } else if (value == "saved") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SavePage(),
            ),
          );
        } else if (value == "logout") {
          logout();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: "profile", child: Text("Profile")),
        PopupMenuItem(value: "saved", child: Text("Saved Photo")),
        PopupMenuItem(value: "logout", child: Text("Logout")),
      ],
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.deepPurpleAccent, width: 2),
        ),
        child: ClipOval(
          child: (userModel?.avatar == null || userModel!.avatar!.isEmpty)
              ? const Icon(Icons.person, color: Colors.white70)
              : Image.network(
                  "http://127.0.0.1:8000/${userModel!.avatar}",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.person, color: Colors.white70);
                  },
                ),
        ),
      ),
    ),
    const SizedBox(width: 12),
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
                      ).then((_) {
                        checkLoginStatus();
                        fetchPhotos(); // Refresh photos setelah login
                      });
                    },
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text("Login",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
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
                      ).then((_) {
                        checkLoginStatus();
                        fetchPhotos(); // Refresh photos setelah register
                      });
                    },
                    child: const Text("Register",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
          ],
        ),
      ),
      // INI YANG PENTING - Gunakan IndexedStack
      body: IndexedStack(
        index: currentIndex,
        children: [
          _buildBody(), // Index 0 - Home
          const SearchPage(), // Index 1 - Search
          const UploadPage(), // Index 2 - Upload
          const MyBoardsPage(), // Index 3 - Board
          const ProfilePage(), // Index 4 - Profile
        ],
      ),
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

  Widget _buildBody() {
    if (!isLoggedIn) {
      return _buildEmptyState(
        icon: Icons.lock_outline,
        title: "Anda Belum Login",
        subtitle: "Silakan login untuk melihat konten",
        actionButton: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            ).then((_) {
              checkLoginStatus();
              fetchPhotos();
            });
          },
          icon: const Icon(Icons.login),
          label: const Text("Login Sekarang"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurpleAccent,
        ),
      );
    }

    if (error) {
      return _buildEmptyState(
        icon: Icons.error_outline,
        title: "Terjadi Kesalahan",
        subtitle: "Gagal memuat foto",
        actionButton: ElevatedButton.icon(
          onPressed: fetchPhotos,
          icon: const Icon(Icons.refresh),
          label: const Text("Coba Lagi"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    if (photos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.photo_library_outlined,
        title: "Belum Ada Foto",
        subtitle: "Mulai upload foto untuk membuat koleksi Anda",
        actionButton: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              currentIndex = 2; // Pindah ke tab Upload
            });
          },
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text("Upload Foto"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return _buildMasonryGrid();
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? actionButton,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2332),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 80,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 32),
              actionButton,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMasonryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columnCount;
        double screenWidth = constraints.maxWidth;

        if (screenWidth >= 1200) {
          columnCount = 5;
        } else if (screenWidth >= 900) {
          columnCount = 4;
        } else if (screenWidth >= 600) {
          columnCount = 3;
        } else {
          columnCount = 2;
        }

        return MasonryGridView(
          columnCount: columnCount,
          photos: photos,
          onPhotoTap: (photo) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PhotoDetailPage(photo: photo),
              ),
            );
          },
        );
      },
    );
  }
}

// Custom Masonry Grid Widget (Pinterest Style)
class MasonryGridView extends StatelessWidget {
  final int columnCount;
  final List<Photo> photos;
  final Function(Photo) onPhotoTap;

  const MasonryGridView({
    Key? key,
    required this.columnCount,
    required this.photos,
    required this.onPhotoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<List<Photo>> columns = List.generate(columnCount, (_) => []);
    
    for (int i = 0; i < photos.length; i++) {
      columns[i % columnCount].add(photos[i]);
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(columnCount, (columnIndex) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: columnIndex == 0 ? 0 : 4,
                  right: columnIndex == columnCount - 1 ? 0 : 4,
                ),
                child: Column(
                  children: columns[columnIndex].map((photo) {
                    return _buildPhotoCard(photo);
                  }).toList(),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(Photo photo) {
    final String imagePath = "http://127.0.0.1:8000/${photo.imagePath}";

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onPhotoTap(photo),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          color: const Color(0xFF1A2332),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.deepPurpleAccent,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          color: const Color(0xFF1A2332),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}