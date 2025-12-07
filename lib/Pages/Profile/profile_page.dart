import 'package:aplikasi_gallery/Pages/Board/my_board_page.dart';
import 'package:aplikasi_gallery/Pages/search_page.dart';
import 'package:flutter/material.dart';
import '../../model/user.dart';
import '../../model/photo.dart';
import '../../Services/photo_service.dart';
import '../../Services/user_service.dart';
import '../Photos/detail_page.dart';
import 'update_profile_page.dart';
import '../home_page.dart';
import '../Photos/upload_page.dart';
import '../Photos/edit_foto.dart';
import '../../Services/follow_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? user;
  List<Photo> userPhotos = [];
  bool loading = true;
  List<Map<String, dynamic>> followers = [];
  List<Map<String, dynamic>> following = [];
  final FollowService _followService = FollowService();

  final PhotoService _photoService = PhotoService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void _navigateToEditProfile() {
  if (user == null) return; // pastikan user sudah terload

  print("Tombol Edit Profile ditekan"); // debug
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditProfilePage(userModel: user!),
    ),
  ).then((_) {
    loadUserData(); // reload data setelah kembali
  });
}


  Future<void> loadUserData() async {
  setState(() => loading = true);

  try {
    final profile = await _userService.getProfile();
    final photos = await _photoService.getUserPhotos();
    final userFollowers = await _followService.getFollowers(profile.id);
    final userFollowing = await _followService.getFollowing(profile.id);

    setState(() {
      user = profile;
      userPhotos = photos;
      followers = userFollowers;
      following = userFollowing;
      loading = false;
    });
  } catch (e) {
    setState(() => loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Gagal memuat data: $e"),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C63FF),
              ),
            )
          : user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "User tidak ditemukan",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // ---------------- Modern Header ----------------
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF6C63FF),
                              const Color(0xFF4834DF),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Column(
                            children: [
                              // Edit Button
                              Padding(
  padding: const EdgeInsets.all(16.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      InkWell(
        onTap: _navigateToEditProfile,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.edit_outlined, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                "Edit Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),

                              // Avatar with gradient border
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.5),
                                    ],
                                  ),
                                ),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF0A0E21),
                                      width: 4,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: user!.avatar == null ||
                                            user!.avatar!.isEmpty
                                        ? Container(
                                            color: Colors.white24,
                                            child: Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.white.withOpacity(0.7),
                                            ),
                                          )
                                        : Image.network(
                                            "http://127.0.0.1:8000/${user!.avatar}",
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.white24,
                                                child: Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.white.withOpacity(0.7),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Name
                              Text(
                                user!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Bio
                              if (user!.bio != null && user!.bio!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    user!.bio!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              const SizedBox(height: 24),
                              // Stats Card
                              Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 24),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatItem(
                                          userPhotos.length.toString(),
                                          "Photos",
                                          Icons.photo_library_outlined,
                                        ),
                                        Container(
                                          width: 1,
                                          height: 40,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        _buildStatItem(
                                          followers.length.toString(),
                                          "Followers",
                                          Icons.people_outline,
                                        ),
                                        Container(
                                          width: 1,
                                          height: 40,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        _buildStatItem(
                                          following.length.toString(),
                                          "Following",
                                          Icons.person_add_outlined,
                                        ),
                                      ],
                                    ),
                                  ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ---------------- Section Title ----------------
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "My Gallery",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ---------------- Photos Grid ----------------
                    userPhotos.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.photo_library_outlined,
                                      size: 80,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Belum ada foto",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Mulai unggah foto pertama Anda",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.3),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : // Ganti bagian SliverGrid di profile_page.dart dengan kode ini:

// Di dalam userPhotos.isEmpty ? ... : 
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    child: LayoutBuilder(
      builder: (context, constraints) {
        int columnCount;
        double screenWidth = constraints.maxWidth;

        if (screenWidth >= 900) {
          columnCount = 4;
        } else if (screenWidth >= 600) {
          columnCount = 3;
        } else {
          columnCount = 2;
        }

        // Bagi foto ke dalam kolom
        List<List<Photo>> columns = List.generate(columnCount, (_) => []);
        
        for (int i = 0; i < userPhotos.length; i++) {
          columns[i % columnCount].add(userPhotos[i]);
        }

        return Row(
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
                    final imageUrl = photo.imagePath.startsWith('http')
                        ? photo.imagePath
                        : "http://127.0.0.1:8000/${photo.imagePath}";

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PhotoDetailPage(photo: photo),
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'photo_${photo.imagePath}',
                          child: Stack(
                            children: [
                              Container(
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
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return AspectRatio(
                                        aspectRatio: 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A1F3A),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: progress.expectedTotalBytes != null
                                                  ? progress.cumulativeBytesLoaded /
                                                      progress.expectedTotalBytes!
                                                  : null,
                                              color: const Color(0xFF6C63FF),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return AspectRatio(
                                        aspectRatio: 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A1F3A),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.broken_image_outlined,
                                                color: Colors.white.withOpacity(0.3),
                                                size: 40,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Error",
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.3),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Tombol Edit/Delete
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        if (photo.id == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Photo ID tidak tersedia')),
                                          );
                                          return;
                                        }

                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditPhotoPage(photo: photo),
                                          ),
                                        );

                                        await loadUserData();
                                      } else if (value == 'delete') {
                                        bool? confirmed = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Hapus Foto'),
                                            content: const Text('Apakah Anda yakin ingin menghapus foto ini?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Batal'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          try {
                                            await _photoService.deletePhoto(photo.id!);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Foto berhasil dihapus')),
                                            );
                                            await loadUserData();
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Gagal menghapus foto: $e')),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }),
        );
      },
    ),
  ),
)

                  ],
                ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}