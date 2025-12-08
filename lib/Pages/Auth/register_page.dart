import 'package:flutter/material.dart';
import 'package:aplikasi_gallery/Services/api_service.dart';
import 'login_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/gestures.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _isHovering = false;
  bool agreeTerms = false;
  bool isLoading = false;

  Future<void> registerUser() async {
  final name = nameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text.trim();
  final confirmPassword = confirmPasswordController.text.trim();

  if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Semua field harus diisi")),
    );
    return;
  }

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password tidak sama")),
    );
    return;
  }

  if (!agreeTerms) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Anda harus menyetujui syarat & ketentuan")),
    );
    return;
  }

  setState(() => isLoading = true);

  final response = await ApiService.register(
    name,
    email,
    password,
    confirmPassword,
  );

  setState(() => isLoading = false);

  if (response["success"]) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registrasi berhasil!")),
    );

    Navigator.pop(context); // kembali ke login
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response["message"] ?? "Gagal daftar")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1120),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// LOGO
            Column(
              children: [
                FaIcon(
                FontAwesomeIcons.images,
                size: 60,
                color: Colors.purpleAccent,
              ),
                const SizedBox(height: 10),
                const Text(
                  "PinSpace",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Buat Akun Baru",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Text(
                  "Bergabunglah dan bagikan karya terbaik Anda",
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// CARD FORM
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C2C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInput(
                    controller: nameController,
                    label: "Nama Lengkap",
                    hint: "Masukkan nama lengkap",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 15),
                  _buildInput(
                    controller: emailController,
                    label: "Email",
                    hint: "nama@email.com",
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 15),
                  _buildInput(
                    controller: passwordController,
                    label: "Password",
                    hint: "••••••••",
                    icon: Icons.lock,
                    obscure: true,
                  ),
                  const SizedBox(height: 15),
                  _buildInput(
                    controller: confirmPasswordController,
                    label: "Konfirmasi Password",
                    hint: "••••••••",
                    icon: Icons.lock_outline,
                    obscure: true,
                  ),

                  const SizedBox(height: 10),

                  /// Checkbox syarat
                  Row(
  children: [
    Checkbox(
      value: agreeTerms,
      onChanged: (v) => setState(() => agreeTerms = v!),
      activeColor: Colors.purpleAccent,
    ),
    Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
            children: [
              const TextSpan(text: "Saya setuju dengan "),
              TextSpan(
                text: "Syarat & Ketentuan",
                style: TextStyle(
                  color: _isHovering ? Colors.purpleAccent : Colors.white.withOpacity(0.8),
                  decoration: TextDecoration.none,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Tap polos, tidak redirect
                  },
              ),
            ],
          ),
        ),
      ),
    ),
  ],
),


                  const SizedBox(height: 15),

                  /// Tombol Register
                  SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Buat Akun",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),


                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white24)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Atau daftar dengan",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _socialButton(FontAwesomeIcons.google),
                      _socialButton(Icons.facebook),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Login Link
            Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sudah punya akun?",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 5),
                    MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );

                          },
                          child: const Text(
                            "Login sekarang",
                            style: TextStyle(
                              color: Colors.purpleAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                  ],
                )

          ],
        ),
      ),
    );
  }

  /// INPUT FIELD COMPONENT
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF111322),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white54),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
            ),
          ),
        ),
      ],
    );
  }

  /// SOCIAL LOGIN BUTTON
  Widget _socialButton(IconData icon) {
    return Container(
      width: 90,
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFF111322),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white70, size: 28),
    );
  }
}
