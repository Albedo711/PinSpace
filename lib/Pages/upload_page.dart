import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/photo_service.dart';
import '../Pages/home_page.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  Uint8List? imageBytes;       // for Web
  io.File? imageFile;          // for Android/iOS
  final picker = ImagePicker();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  String selectedCategory = "Nature";

  final PhotoService _photoService = PhotoService();

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    if (kIsWeb) {
      // ---- WEB → pakai bytes ----
      imageBytes = await picked.readAsBytes();
      imageFile = null;
    } else {
      // ---- Android/iOS → pakai File ----
      imageFile = io.File(picked.path);
      imageBytes = null;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1523),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2332),
        title: const Text("Upload New Photo", style: TextStyle(color: Colors.white)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------- PHOTO PREVIEW --------------------------------
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
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cloud_upload_outlined, size: 50, color: Colors.white70),
                          SizedBox(height: 10),
                          Text("Click to upload image",
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
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

            // -------------------------------- TITLE --------------------------------
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

            // -------------------------------- DESCRIPTION --------------------------------
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

            // -------------------------------- CATEGORY --------------------------------
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

            // -------------------------- BUTTON UPLOAD --------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  },
  child: const Text("Cancel", style: TextStyle(color: Colors.white)),
),

                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload, color: Colors.white),
                  label: const Text("Upload Photo", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    if (imageBytes == null && imageFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select an image")),
                      );
                      return;
                    }

                    try {
                      await _photoService.uploadPhoto(
                        title: titleController.text,
                        description: descController.text,
                        category: selectedCategory,
                        fileBytes: imageBytes,
                        file: imageFile,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Upload berhasil!")),
                      );

                      Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => HomePage()),
);

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Upload gagal: $e")),
                      );
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
