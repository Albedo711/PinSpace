import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Services/board_service.dart';
import '../../model/board.dart';

class EditBoardPage extends StatefulWidget {
  final Board board;
  
  const EditBoardPage({super.key, required this.board});

  @override
  State<EditBoardPage> createState() => _EditBoardPageState();
}

class _EditBoardPageState extends State<EditBoardPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final BoardService _boardService = BoardService();
  final ImagePicker _picker = ImagePicker();


  bool _isLoading = false;
  
  // Untuk mobile (Android/iOS)
  File? _coverImageFile;
  
  // Untuk web - simpan XFile langsung
  XFile? _coverImageWeb;
  
  // Untuk preview bytes (web)
  Uint8List? _webImageBytes;
  
  // Track apakah user mengganti gambar
  bool _hasNewImage = false;
  
  // Track apakah user menghapus gambar
  bool _imageRemoved = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.board.name);
    _descriptionController = TextEditingController(text: widget.board.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Web: baca bytes untuk preview
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _coverImageWeb = pickedFile;
            _webImageBytes = bytes;
            _hasNewImage = true;
            _imageRemoved = false;
          });
        } else {
          // Mobile: convert ke File
          setState(() {
            _coverImageFile = File(pickedFile.path);
            _hasNewImage = true;
            _imageRemoved = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _coverImageFile = null;
      _coverImageWeb = null;
      _webImageBytes = null;
      _hasNewImage = false;
      _imageRemoved = true;
    });
  }

  Future<void> _updateBoard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Gunakan image sesuai platform jika ada perubahan
      dynamic imageToUpload;
      if (_hasNewImage) {
        if (kIsWeb) {
          imageToUpload = _coverImageWeb; // XFile untuk web
        } else {
          imageToUpload = _coverImageFile; // File untuk mobile
        }
      }
      
      await _boardService.updateBoard(
        boardId: widget.board.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        coverImage: imageToUpload,
        removeImage: _imageRemoved,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Board berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true untuk refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update board: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteBoard() async {
    // Konfirmasi delete
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        title: const Text(
          'Hapus Board?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${widget.board.name}"? Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus',
            style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _boardService.deleteBoard(widget.board.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Board berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true untuk refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal hapus board: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildImagePreview() {
    // Jika ada gambar baru
    if (_hasNewImage) {
      if (kIsWeb && _webImageBytes != null) {
        return Image.memory(
          _webImageBytes!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      } else if (!kIsWeb && _coverImageFile != null) {
        return Image.file(
          _coverImageFile!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      }
    }
    
    // Jika gambar tidak dihapus, tampilkan gambar lama
    if (!_imageRemoved && widget.board.coverImage != null) {
      return Image.network(
        "http://127.0.0.1:8000/${widget.board.coverImage}",
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }
    
    // Placeholder jika tidak ada gambar
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: Colors.deepPurpleAccent,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Add Cover Image',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Optional',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  bool get _hasImage {
    return (_hasNewImage && ((kIsWeb && _webImageBytes != null) || (!kIsWeb && _coverImageFile != null))) ||
           (!_imageRemoved && widget.board.coverImage != null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1523),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2332),
        elevation: 4,
        shadowColor: Colors.black45,
        title: const Text(
          'Edit Board',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Delete Button
          IconButton(
            onPressed: _isLoading ? null : _deleteBoard,
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete Board',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image Section
              GestureDetector(
                onTap: _isLoading ? null : _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2332),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white24,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _hasImage
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: _buildImagePreview(),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: _removeImage,
                                icon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              const Text(
                'Board Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                style: const TextStyle(color: Colors.white),
                maxLength: 255,
                decoration: InputDecoration(
                  hintText: 'e.g., Travel Inspiration',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1A2332),
                  counterStyle: const TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepPurpleAccent,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Board name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Description Field
              const Text(
                'Description',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                enabled: !_isLoading,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'What\'s this board about? (optional)',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1A2332),
                  counterStyle: const TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepPurpleAccent,
                      width: 2,
                    ),
                  ),
                ),
              ),
             
             
              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateBoard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update Board',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}