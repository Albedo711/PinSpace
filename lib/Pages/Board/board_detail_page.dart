import 'package:flutter/material.dart';
import '../../Services/board_service.dart';
import '../../model/board.dart';
import '../../model/photo.dart';
import '../Photos/detail_page.dart';
import 'update_board_page.dart';

class BoardDetailPage extends StatefulWidget {
  final Board board;

  const BoardDetailPage({
    Key? key,
    required this.board,
  }) : super(key: key);

  @override
  _BoardDetailPageState createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  final BoardService _boardService = BoardService();
  List<Photo> photos = [];
  bool loading = true;
  bool error = false;
  String errorMessage = '';
  late Board currentBoard;

  @override
  void initState() {
    super.initState();
    currentBoard = widget.board;
    _fetchBoardPhotos();
  }

  Future<void> _fetchBoardPhotos() async {
    try {
      setState(() {
        loading = true;
        error = false;
        errorMessage = '';
      });

      final result = await _boardService.getBoardPhotos(currentBoard.id);

      setState(() {
        photos = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
        errorMessage = e.toString();
      });
      print("Error fetching board photos: $e");
    }
  }

  Future<void> _removePhotoFromBoard(Photo photo) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A2332),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Hapus Foto?",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Apakah Anda yakin ingin menghapus foto ini dari board?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Hapus"),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _boardService.removePhotoFromBoard(
          boardId: currentBoard.id,
          photoId: photo.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto berhasil dihapus dari board'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          _fetchBoardPhotos(); // Refresh
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deleteBoard() async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A2332),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Hapus Board?",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Apakah Anda yakin ingin menghapus board ini? Tindakan ini tidak dapat dibatalkan.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Hapus"),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _boardService.deleteBoard(currentBoard.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Board berhasil dihapus'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true); // Return true to indicate deletion
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1523),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF1A2332),
      elevation: 4,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Edit button
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditBoardPage(board: currentBoard),
              ),
            ).then((updatedBoard) {
              if (updatedBoard != null && updatedBoard is Board) {
                setState(() {
                  currentBoard = updatedBoard;
                });
              }
            });
          },
          tooltip: "Edit Board",
        ),
        // Delete button
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: _deleteBoard,
          tooltip: "Hapus Board",
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader() {
    final coverUrl = currentBoard.coverImage != null && currentBoard.coverImage!.isNotEmpty
        ? "http://127.0.0.1:8000/${currentBoard.coverImage}"
        : null;

    return Container(
      color: const Color(0xFF1A2332),
      child: Column(
        children: [
          // Cover Image
          if (coverUrl != null)
            Image.network(
              coverUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderCover();
              },
            )
          else
            _buildPlaceholderCover(),

          // Board Info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentBoard.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: currentBoard.isPrivate
                            ? Colors.red.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            currentBoard.isPrivate ? Icons.lock : Icons.public,
                            color: currentBoard.isPrivate
                                ? Colors.redAccent
                                : Colors.greenAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currentBoard.isPrivate ? "Private" : "Public",
                            style: TextStyle(
                              color: currentBoard.isPrivate
                                  ? Colors.redAccent
                                  : Colors.greenAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (currentBoard.description != null &&
                    currentBoard.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    currentBoard.description!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.photo_library,
                      color: Colors.deepPurpleAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${photos.length} Foto",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      width: double.infinity,
      height: 200,
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
          Icons.dashboard,
          color: Colors.white54,
          size: 80,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.deepPurpleAccent,
          ),
        ),
      );
    }

    if (error) {
      return SliverFillRemaining(
        child: _buildEmptyState(
          icon: Icons.error_outline,
          title: "Terjadi Kesalahan",
          subtitle: errorMessage.isEmpty
              ? "Gagal memuat foto"
              : errorMessage,
          actionButton: ElevatedButton.icon(
            onPressed: _fetchBoardPhotos,
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
        ),
      );
    }

    if (photos.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(
          icon: Icons.photo_library_outlined,
          title: "Belum Ada Foto",
          subtitle: "Tambahkan foto ke board ini dari halaman saved photos",
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverToBoxAdapter(
        child: _buildMasonryGrid(),
      ),
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
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF1A2332),
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

        List<List<Photo>> columns = List.generate(columnCount, (_) => []);

        for (int i = 0; i < photos.length; i++) {
          columns[i % columnCount].add(photos[i]);
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
                    return _buildPhotoCard(photo);
                  }).toList(),
                ),
              ),
            );
          }),
        );
      },
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PhotoDetailPage(photo: photo),
              ),
            );
          },
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
                  // Remove button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removePhotoFromBoard(photo),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
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