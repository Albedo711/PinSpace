import 'package:flutter/material.dart';
import '../model/photo.dart';
import '../model/board.dart';
import '../Services/board_service.dart';

class AddToBoardSheet extends StatefulWidget {
  final Photo photo;
  final BoardService boardService;

  const AddToBoardSheet({
    Key? key,
    required this.photo,
    required this.boardService,
  }) : super(key: key);

  @override
  _AddToBoardSheetState createState() => _AddToBoardSheetState();
}

class _AddToBoardSheetState extends State<AddToBoardSheet> {
  List<Board> boards = [];
  bool loading = true;
  bool error = false;
  Set<int> addingToBoard = {}; // Track which boards are being added to

  @override
  void initState() {
    super.initState();
    _loadBoards();
  }

  Future<void> _loadBoards() async {
    try {
      setState(() {
        loading = true;
        error = false;
      });

      final result = await widget.boardService.getBoards();

      setState(() {
        boards = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
      });
      print("Error loading boards: $e");
    }
  }

  Future<void> _addPhotoToBoard(Board board) async {
    try {
      setState(() {
        addingToBoard.add(board.id);
      });

      await widget.boardService.addPhotoToBoard(
        boardId: board.id,
        photoId: widget.photo.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto berhasil ditambahkan ke "${board.name}"'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
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
    } finally {
      if (mounted) {
        setState(() {
          addingToBoard.remove(board.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2332),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tambahkan ke Board",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Content
          Flexible(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(48.0),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.deepPurpleAccent,
          ),
        ),
      );
    }

    if (error) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white54,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "Gagal memuat board",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadBoards,
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Lagi"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (boards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.dashboard_outlined,
              color: Colors.white54,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "Belum ada board",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Buat board terlebih dahulu",
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: boards.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final board = boards[index];
        final isAdding = addingToBoard.contains(board.id);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isAdding ? null : () => _addPhotoToBoard(board),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1523),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white12,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Board cover or icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2332),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: board.coverImage != null && board.coverImage!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              "http://127.0.0.1:8000/${board.coverImage}",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.dashboard,
                                  color: Colors.white54,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.dashboard,
                            color: Colors.white54,
                          ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Board info
                  Expanded(
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
                        Row(
                          children: [
                            Icon(
                              board.isPrivate ? Icons.lock : Icons.public,
                              size: 14,
                              color: Colors.white54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${board.photosCount ?? 0} foto",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Add button or loading
                  if (isAdding)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                    )
                  else
                    const Icon(
                      Icons.add_circle_outline,
                      color: Colors.deepPurpleAccent,
                      size: 28,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}