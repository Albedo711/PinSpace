import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/photo_service.dart';
import '../model/photo.dart';
import 'home_page.dart';

class EditPhotoPage extends StatefulWidget {
  final Photo photo;

  const EditPhotoPage({super.key, required this.photo});

  @override
  _EditPhotoPageState createState() => _EditPhotoPageState();
}

class _EditPhotoPageState extends State<EditPhotoPage> {
  Uint8List? imageBytes;       // for Web
  io.File? imageFile;          // for Android/iOS
  final picker = ImagePicker();

  late TextEditingController titleController;
  late TextEditingController descController;
  late String selectedCategory;

  final PhotoService _photoService = PhotoService();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.photo.title);
    descController = TextEditingController(text: widget.photo.description ?? "");
    selectedCategory = widget.photo.category ?? "Nature";
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    if (kIsWeb) {
      imageBytes = await picked.readAsBytes();
      imageFile = null;
    } else {
      imageFile = io.File(picked.path);
      imageBytes = null;
    }

    setState(() {});
  }

  Future<void> updatePhoto() async {
    if ((imageBytes == null && imageFile == null) && titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a title or image")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await _photoService.updatePhoto(
        widget.photo.id,
        title: titleController.text,
        description: descController.text,
        category: selectedCategory,
        fileBytes: imageBytes,
        file: imageFile,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto berhasil diperbarui!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update gagal: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1523),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2332),
        title: const Text("Edit Photo", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PHOTO PREVIEW
            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                height: 230,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2332),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: imageBytes == null && imageFile == null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          "http://192.168.100.44:8000/${widget.photo.imagePath}",
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Image.memory(imageBytes!, fit: BoxFit.cover)
                            : Image.file(imageFile!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 25),

            // TITLE
            const Text("Title", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1A2332),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // DESCRIPTION
            const Text("Description", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            TextField(
              controller: descController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1A2332),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // CATEGORY
            const Text("Category", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              dropdownColor: const Color(0xFF1A2332),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1A2332),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: ["Nature", "Art", "Technology", "Food", "Travel", "Animals"]
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: const TextStyle(color: Colors.white)),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => selectedCategory = value!),
            ),
            const SizedBox(height: 30),

            // BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save Changes", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: loading ? null : updatePhoto,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
