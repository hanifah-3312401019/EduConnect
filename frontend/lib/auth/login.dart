import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../utils/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:frontend/env/api_base_url.dart';
import 'package:frontend/orangtua/dashboard_orangtua.dart';
import 'package:shared_preferences/shared_preferences.dart';

String globalAuthToken = '';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ==============================
  // POPUP LOGIN SUKSES
  // ==============================
  void showSuccessLoginDialog(BuildContext context, String role, Function onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Login Berhasil",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text("Anda telah berhasil login sebagai $role"),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm(); // Lanjutkan navigasi setelah popup
              },
            ),
          ],
        );
      },
    );
  }

  // ==============================
  // FUNGSI LOGIN
  // ==============================
  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);

    final baseUrl = ApiConfig.baseUrl;

    final response = await http.post(
      Uri.parse("$baseUrl/api/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"Email": email, "Kata_Sandi": password}),
    );

    setState(() => _isLoading = false);

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final role = data['role'];
      final token = data['token'];

      final prefs = await SharedPreferences.getInstance();

      // Simpan role & token
      await prefs.setString('token', token);
      await prefs.setString('role', role);

      // Simpan info guru jika role guru
      if (role == "guru") {
        final guruId = data['profile']['Guru_Id'];
        final namaGuru = data['profile']['Nama'];

        await prefs.setInt('Guru_Id', guruId);
        await prefs.setString('Guru_Nama', namaGuru);

        print("Guru_Id disimpan: $guruId");
        print("Guru_Nama disimpan: $namaGuru");
      }

      print('Login berhasil! Role: $role');
      globalAuthToken = token;

      // Tampilkan popup login sukses → setelah itu redirect dashboard sesuai role
      showSuccessLoginDialog(context, role, () {
        if (role == "guru") {
          Navigator.pushReplacementNamed(context, '/guru/dashboard');
        } else if (role == "orangtua") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage()),
          );
        } else if (role == "admin") {
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
        }
      });

    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['message'] ?? 'Terjadi kesalahan';

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  // =======================================================
  // BUILD METHOD (LAYOUT)
  // =======================================================
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return constraints.maxWidth > 600
                ? _buildDesktopLayout()
                : _buildMobileLayout();
          },
        ),
      ),
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: const EdgeInsets.all(40),
        child: Row(
          children: [
            Expanded(flex: 1, child: _buildDesktopLeftSide()),
            const SizedBox(width: 60),
            Expanded(flex: 1, child: _buildDesktopLoginForm()),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLeftSide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset('assets/images/Logo.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: AppConstants.primaryColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppConstants.appSubtitle,
          style: TextStyle(
            fontSize: 18,
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLoginForm() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFormHeader(),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'masukan email anda',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _passwordController,
            label: 'Kata Sandi',
            hint: 'masukan kata sandi',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey[500],
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 32),
          _buildLoginButton(),
          const SizedBox(height: 24),
          _buildFooter(),
        ],
      ),
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          _buildMobileHeaderSection(),
          const SizedBox(height: 40),
          _buildMobileLoginForm(),
          const SizedBox(height: 40),
          _buildFooter(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMobileHeaderSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset('assets/images/Logo.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildSubtitleCard(),
        ],
      ),
    );
  }

  Widget _buildMobileLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppConstants.formContainerDecoration,
      child: Column(
        children: [
          _buildFormHeader(),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'masukan email anda',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            label: 'Kata Sandi',
            hint: 'masukan kata sandi',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey[500],
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 24),
          _buildLoginButton(),
        ],
      ),
    );
  }

  // ==================== SHARED COMPONENTS ====================
  Widget _buildFormHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_outline,
            color: AppConstants.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Masuk ke Akun',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSubtitleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        AppConstants.appSubtitle,
        style: TextStyle(
          fontSize: 14,
          color: AppConstants.primaryColor,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Belum punya akun? Hubungi administrator sekolah',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
