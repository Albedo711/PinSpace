import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/board_service.dart';
import '../../model/board.dart';
import '../../model/user.dart';
import '../../Services/user_service.dart';
import '../home_page.dart';
import '../search_page.dart';
import '../Photos/upload_page.dart';
import '../Profile/profile_page.dart';
import '../Auth/login_page.dart';
import '../Auth/register_page.dart';
import 'create_board_page.dart';
import 'update_board_page.dart';
import 'board_detail_page.dart'; // TAMBAHKAN IMPORT INI

class MyBoardsPage extends StatefulWidget {
  const MyBoardsPage({super.key});

  @override
  State<MyBoardsPage> createState() => _MyBoardsPageState();
}

class _MyBoardsPageState extends State<MyBoardsPage> {
  final BoardService _boardService = BoardService();
  final UserService _userService = UserService();
  List<Board> boards = [];
  bool loading = true;
  bool error = false;
  bool isLoggedIn = false;
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    fetchBoards();
    loadUserData(); 
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
      loadUserData();
    }
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      isLoggedIn = false;
      boards = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logout berhasil")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  Future<void> fetchBoards() async {
    try {
      final result = await _boardService.getBoards();
      setState(() {
        boards = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1523),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateBoardPage(), 
                  ),
                ).then((_) => fetchBoards()); 
              },
              backgroundColor: Colors.deepPurpleAccent,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Create Board",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 4,
            )
          : null,
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (!isLoggedIn) {
      return _buildEmptyState(
        icon: Icons.lock_outline,
        title: "Anda Belum Login",
        subtitle: "Silakan login untuk melihat boards Anda",
        actionButton: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            ).then((_) => checkLoginStatus());
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
        child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
      );
    }

    if (error) {
      return _buildEmptyState(
        icon: Icons.error_outline,
        title: "Terjadi Kesalahan",
        subtitle: "Gagal memuat boards",
        actionButton: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              loading = true;
              error = false;
            });
            fetchBoards();
          },
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

    if (boards.isEmpty) {
      return _buildEmptyState(
        icon: Icons.dashboard_outlined,
        title: "Belum Ada Board",
        subtitle: "Buat board pertama Anda untuk mengorganisir foto",
        actionButton: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateBoardPage(), 
              ),
            ).then((_) => fetchBoards());
          },
          icon: const Icon(Icons.add),
          label: const Text("Buat Board"),
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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: boards.length,
      itemBuilder: (context, index) {
        final board = boards[index];
        final cover = board.coverImage != null
            ? "http://127.0.0.1:8000/${board.coverImage}"
            : null;

        return GestureDetector(
          // UPDATE BAGIAN INI - Tambahkan navigasi ke BoardDetailPage
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BoardDetailPage(board: board),
              ),
            ).then((deleted) {
              // Refresh boards jika board dihapus dari detail page
              if (deleted == true) {
                fetchBoards();
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: cover != null
                          ? Image.network(
                              cover,
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 130,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.deepPurpleAccent.withOpacity(0.3),
                                    Colors.purpleAccent.withOpacity(0.2),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.photo_library_outlined,
                                  color: Colors.white54,
                                  size: 48,
                                ),
                              ),
                            ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              board.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              board.description ?? "Tidak ada deskripsi",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 4),
                                      
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.photo,
                                      color: Colors.white54,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${board.photosCount}",
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Edit Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Navigate ke halaman edit board
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditBoardPage(board: board),
                          ),
                        ).then((_) => fetchBoards()); // Refresh setelah edit
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              padding: const EdgeInsets.all(32),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
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
}