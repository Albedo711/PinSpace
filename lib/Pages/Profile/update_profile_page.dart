import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/user_service.dart';
import '../../model/user.dart';
import '../home_page.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final UserModel userModel;

  const EditProfilePage({super.key, required this.userModel});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Uint8List? _avatarBytes;
  String? _avatarFilePath;
  bool loading = false;

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userModel.name);
    _emailController = TextEditingController(text: widget.userModel.email);
    _bioController = TextEditingController(text: widget.userModel.bio ?? '');
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _avatarBytes = bytes;
          _avatarFilePath = null;
        });
      } else {
        setState(() {
          _avatarFilePath = pickedFile.path;
          _avatarBytes = null;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      String? avatarPath = _avatarFilePath;

      final updatedUser = await _userService.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        bio: _bioController.text,
        avatarPath: avatarPath,
        avatarBytes: _avatarBytes,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_name", updatedUser.name);
      await prefs.setString("user_email", updatedUser.email);
      await prefs.setString("user_bio", updatedUser.bio ?? '');
      if (updatedUser.avatar != null) {
        await prefs.setString("user_avatar", updatedUser.avatar!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text("Profil berhasil diperbarui!"),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text("Gagal memperbarui profil: $e")),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _buildAvatar() {
    Widget avatarWidget;

    if (_avatarBytes != null) {
      avatarWidget = Image.memory(
        _avatarBytes!,
        width: 140,
        height: 140,
        fit: BoxFit.cover,
      );
    } else if (_avatarFilePath != null) {
      avatarWidget = Image.file(
        File(_avatarFilePath!),
        width: 140,
        height: 140,
        fit: BoxFit.cover,
      );
    } else if (widget.userModel.avatar != null) {
      avatarWidget = Image.network(
        "http://127.0.0.1:8000/${widget.userModel.avatar}",
        width: 140,
        height: 140,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6C63FF).withOpacity(0.3),
                  const Color(0xFF4834DF).withOpacity(0.3),
                ],
              ),
            ),
            child: const Icon(Icons.person, size: 70, color: Colors.white54),
          );
        },
      );
    } else {
      avatarWidget = Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.3),
              const Color(0xFF4834DF).withOpacity(0.3),
            ],
          ),
        ),
        child: const Icon(Icons.person, size: 70, color: Colors.white54),
      );
    }

    return Stack(
      children: [
        // Glow effect
        Container(
          width: 156,
          height: 156,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
        // Gradient border
        Container(
          width: 156,
          height: 156,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6C63FF),
                const Color(0xFF4834DF),
              ],
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF0A0E21),
                width: 4,
              ),
            ),
            child: ClipOval(child: avatarWidget),
          ),
        ),
        // Camera button
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6C63FF),
                  Color(0xFF4834DF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickAvatar,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6C63FF),
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  const Color(0xFF6C63FF).withOpacity(0.15),
                  const Color(0xFF0A0E21),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: loading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1F3A),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C63FF).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const CircularProgressIndicator(
                            color: Color(0xFF6C63FF),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Menyimpan perubahan...",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              // Avatar
                              _buildAvatar(),
                              const SizedBox(height: 12),
                              Text(
                                "Tap icon untuk mengubah foto",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 40),
                              
                              // Name field
                              _buildTextField(
                                controller: _nameController,
                                label: "Nama Lengkap",
                                icon: Icons.person_outline,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? "Nama wajib diisi"
                                        : null,
                              ),
                              const SizedBox(height: 20),
                              
                              // Email field
                              _buildTextField(
                                controller: _emailController,
                                label: "Email",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Email wajib diisi";
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return "Format email tidak valid";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              // Bio field
                              _buildTextField(
                                controller: _bioController,
                                label: "Bio (Opsional)",
                                icon: Icons.info_outline,
                                maxLines: 4,
                              ),
                              const SizedBox(height: 32),
                              
                              // Info card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6C63FF).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.info_outline,
                                        color: Color(0xFF6C63FF),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        "Informasi profil akan terlihat oleh pengguna lain",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // Save button
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF6C63FF),
                                      Color(0xFF4834DF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6C63FF).withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _saveProfile,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            "Simpan Perubahan",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}