import 'package:flutter/material.dart';
import '../Services/save_service.dart';
import '../Services/board_service.dart';
import '../model/photo.dart';
import 'Photos/detail_page.dart';
import 'add_page.dart';

class SavePage extends StatefulWidget {
  const SavePage({super.key});

  @override
  _SavePageState createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  final SaveService _saveService = SaveService();
  final BoardService _boardService = BoardService();
  List<Photo> savedPhotos = [];
  bool loading = true;
  bool error = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSavedPhotos();
  }

  Future<void> fetchSavedPhotos() async {
    try {
      setState(() {
        loading = true;
        error = false;
        errorMessage = '';
      });

      final result = await _saveService.getSavedPhotos();
      
      setState(() {
        savedPhotos = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
        errorMessage = e.toString();
      });
      print("Error fetching saved photos: $e");
      
      // Show snackbar with error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showAddToBoardSheet(Photo photo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddToBoardSheet(
        photo: photo,
        boardService: _boardService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1523),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2332),
        elevation: 4,
        shadowColor: Colors.black45,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text(
              "Saved Photos",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (savedPhotos.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${savedPhotos.length}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (savedPhotos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: fetchSavedPhotos,
              tooltip: "Refresh",
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
        subtitle: errorMessage.isEmpty 
            ? "Gagal memuat foto yang disimpan" 
            : errorMessage,
        actionButton: ElevatedButton.icon(
          onPressed: fetchSavedPhotos,
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

    if (savedPhotos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_border,
        title: "Belum Ada Foto Tersimpan",
        subtitle: "Foto yang Anda simpan akan muncul di sini",
        actionButton: ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.explore),
          label: const Text("Jelajahi Foto"),
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
          photos: savedPhotos,
          onPhotoTap: (photo) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PhotoDetailPage(photo: photo),
              ),
            ).then((_) {
              // Refresh saved photos ketika kembali dari detail page
              fetchSavedPhotos();
            });
          },
          onAddToBoard: _showAddToBoardSheet, // Pass callback
          onRefresh: fetchSavedPhotos,
        );
      },
    );
  }
}

// Custom Masonry Grid Widget
class MasonryGridView extends StatelessWidget {
  final int columnCount;
  final List<Photo> photos;
  final Function(Photo) onPhotoTap;
  final Function(Photo) onAddToBoard;
  final VoidCallback onRefresh;

  const MasonryGridView({
    Key? key,
    required this.columnCount,
    required this.photos,
    required this.onPhotoTap,
    required this.onAddToBoard,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<List<Photo>> columns = List.generate(columnCount, (_) => []);

    for (int i = 0; i < photos.length; i++) {
      columns[i % columnCount].add(photos[i]);
    }

    return RefreshIndicator(
      color: Colors.deepPurpleAccent,
      backgroundColor: const Color(0xFF1A2332),
      onRefresh: () async {
        onRefresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                      return _buildPhotoCard(context, photo);
                    }).toList(),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, Photo photo) {
    final String imagePath = "http://127.0.0.1:8000/${photo.imagePath}";

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onPhotoTap(photo),
          onLongPress: () => onAddToBoard(photo),
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
                  // Badge untuk menunjukkan foto tersimpan
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  // Add to board button
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => onAddToBoard(photo),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_to_photos,
                          color: Colors.white,
                          size: 18,
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