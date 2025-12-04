import 'package:flutter/material.dart';
import 'package:aplikasi_gallery/Services/api_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;  // indikator loading

  void doLogin() async {
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email dan password wajib diisi")),
      );
      return;
    }

    setState(() => loading = true);

    final res = await ApiService.login(
      emailCtrl.text.trim(),
      passCtrl.text.trim(),
    );

    setState(() => loading = false);

    if (res["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Berhasil")),
      );

      // pindah ke home
     Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage()),
    );


    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1523),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Icon(Icons.image, size: 60, color: Colors.purpleAccent),
              SizedBox(height: 10),
              Text("PinSpace",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),

              SizedBox(height: 25),

              Text("Selamat Datang Kembali",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text("Masuk ke akun Anda untuk melanjutkan",
                  style: TextStyle(color: Colors.white70)),

              SizedBox(height: 30),

              // ===== CARD FORM =====
              Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Color(0xFF1B2332),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // EMAIL
                    Text("Email", style: TextStyle(color: Colors.white)),
                    SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF121826),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: emailCtrl,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "nama@email.com",
                          hintStyle: TextStyle(color: Colors.white38),
                          prefixIcon: Icon(Icons.email_outlined,
                              color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // PASSWORD
                    Text("Password", style: TextStyle(color: Colors.white)),
                    SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF121826),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: passCtrl,
                        style: TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "••••••••",
                          hintStyle: TextStyle(color: Colors.white38),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // TOMBOL LOGIN
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : doLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: loading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login,color: Colors.white,),
                                  SizedBox(width: 8),
                                  Text("Login",
                                  style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white24)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("Atau login dengan",
                              style: TextStyle(color: Colors.white54)),
                        ),
                        Expanded(child: Divider(color: Colors.white24)),
                      ],
                    ),

                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _socialButton(Icons.g_mobiledata),
                        _socialButton(Icons.facebook),
                        _socialButton(Icons.code),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Belum punya akun?",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, "/register"),
                    child: Text(
                      "Register sekarang",
                      style: TextStyle(
                        color: Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}
