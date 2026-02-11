import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../app/theme.dart';
import '../app/data.dart';
import '../widgets/common_widgets.dart';
import 'siswa_screen.dart';
import 'admin_screen.dart';
import 'firestore_diagnostic.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKeyAdmin = GlobalKey<FormState>();
  final _formKeySiswa = GlobalKey<FormState>();

  // Admin Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Siswa Controllers
  final _namaController = TextEditingController();
  final _nisController = TextEditingController();
  final _kelasController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isAdminMode = true; // Toggle between admin and siswa

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _namaController.dispose();
    _nisController.dispose();
    _kelasController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    if (!_formKeyAdmin.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await DataManager.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      final user = result['user'] as User;

      if (user.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
      } else {
        Helpers.showSnackBar(
          context,
          'Bukan akun admin',
          isError: true,
        );
      }
    } else {
      Helpers.showSnackBar(
        context,
        result['message'] ?? 'Login admin gagal',
        isError: true,
      );
    }
  }

  // Generate kode unik random
  String _generateUniqueCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final timestamp =
        DateTime.now().millisecondsSinceEpoch.toString().substring(7);

    // Format: SISAPRA-XXXX-YYYY (contoh: SISAPRA-A3X9-1234)
    String code = 'SISAPRA-';

    // 4 karakter random
    for (int i = 0; i < 4; i++) {
      code += chars[random.nextInt(chars.length)];
    }

    code += '-$timestamp';

    return code;
  }

  // Cek apakah NIS sudah pernah login
  Future<String?> _getExistingCode(String nis) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('student_code_$nis');
  }

  // Simpan kode unik siswa
  Future<void> _saveStudentCode(String nis, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_code_$nis', code);
  }

  // Simpan data siswa
  Future<void> _saveStudentData(
      String nama, String nis, String kelas, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_nama', nama);
    await prefs.setString('student_nis', nis);
    await prefs.setString('student_kelas', kelas);
    await prefs.setString('student_code', code);
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_role', 'siswa');
  }

  Future<void> _handleSiswaLogin() async {
    if (!_formKeySiswa.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final nis = _nisController.text.trim();
    final nama = _namaController.text.trim();
    final kelas = _kelasController.text.trim();

    await Future.delayed(const Duration(milliseconds: 600));

    String? existingCode = await _getExistingCode(nis);
    String kodeUnik = existingCode ?? _generateUniqueCode();

    if (existingCode == null) {
      await _saveStudentCode(nis, kodeUnik);
    }

    await _saveStudentData(nama, nis, kelas, kodeUnik);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    await _showSuccessDialog(nama, kodeUnik, existingCode != null);

    /// 🔥 BUAT USER SISWA DI SINI
    final user = User(
      id: nis,
      nama: nama,
      email: '$nis@siswa.local',
      role: 'siswa',
      kelas: kelas,
    );

    /// 🔥 KIRIM USER LANGSUNG (INI KUNCI)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SiswaScreen(user: user),
      ),
    );
  }

  Future<void> _showSuccessDialog(
      String nama, String kodeUnik, bool isExisting) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isExisting ? 'Selamat Datang Kembali!' : 'Login Berhasil!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Halo, $nama',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isExisting
                                ? Icons.verified_user_rounded
                                : Icons.vpn_key_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isExisting ? 'Kode Unik Anda' : 'Kode Unik Baru',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        kodeUnik,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isExisting
                            ? 'Gunakan kode ini untuk keperluan admin'
                            : '⚠️ Simpan kode ini untuk keperluan admin',
                        style: TextStyle(
                          fontSize: 11,
                          color: isExisting
                              ? AppColors.textSecondary
                              : Colors.orange.shade800,
                          fontWeight:
                              isExisting ? FontWeight.normal : FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Lanjutkan',
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
        );
      },
    );
  }

  void _toggleMode() {
    setState(() {
      _isAdminMode = !_isAdminMode;
      _animController.reset();
      _animController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: DynamicAppColors.primaryGradient(context)),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo Hero
                          Hero(
                            tag: 'logo',
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                size: 70,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppConstants.appFullName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildRoleButton(
                                    'Admin',
                                    Icons.admin_panel_settings_rounded,
                                    _isAdminMode,
                                    () => _toggleMode(),
                                  ),
                                ),
                                Expanded(
                                  child: _buildRoleButton(
                                    'Form Siswa',
                                    Icons.person_rounded,
                                    !_isAdminMode,
                                    () => _toggleMode(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.1),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _isAdminMode
                                ? _buildAdminLoginCard(context)
                                : _buildSiswaLoginCard(context),
                          ),
                          const SizedBox(height: 24),
                          if (_isAdminMode) _buildDemoInfo(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Theme Toggle Switch di pojok kanan atas
          Positioned(
            top: 16,
            right: 16,
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeColor: Colors.yellow,
                  inactiveThumbColor: Colors.white,
                  activeTrackColor: Colors.white.withOpacity(0.3),
                  inactiveTrackColor: Colors.white.withOpacity(0.5),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: isSelected ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminLoginCard(BuildContext context) {
    return Container(
      key: const ValueKey('admin'),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: DynamicAppColors.overlayBackground(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: _formKeyAdmin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Login Admin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ModernTextField(
              label: 'Email',
              hint: 'Masukkan email admin',
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              validator: (v) => v!.isEmpty ? 'Email harus diisi' : null,
            ),
            const SizedBox(height: 20),
            ModernTextField(
              label: 'Password',
              hint: 'Masukkan password',
              icon: Icons.lock_rounded,
              keyboardType: TextInputType.visiblePassword,
              controller: _passwordController,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) => v!.isEmpty ? 'Password harus diisi' : null,
            ),
            const SizedBox(height: 32),
            GradientButton(
              text: 'Login',
              onPressed: _handleAdminLogin,
              isLoading: _isLoading,
              icon: Icons.login_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiswaLoginCard(BuildContext context) {
    return Container(
      key: const ValueKey('siswa'),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: DynamicAppColors.overlayBackground(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: _formKeySiswa,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                const Text(
                  'Isi Data Siswa',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 87, 86, 86),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Isi data diri untuk masuk',
              style: TextStyle(
                fontSize: 13,
                color: const Color.fromARGB(255, 108, 74, 74).withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            ModernTextField(
              label: 'Nama Lengkap',
              hint: 'Masukkan nama lengkap',
              icon: Icons.badge_rounded,
              keyboardType: TextInputType.name,
              controller: _namaController,
              validator: (v) => v!.isEmpty ? 'Nama lengkap harus diisi' : null,
            ),
            const SizedBox(height: 16),

            ModernTextField(
              label: 'NIS',
              hint: 'Masukkan NIS (4 digit)',
              icon: Icons.numbers_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: _nisController,
              maxLength: 4,
              validator: (v) {
                if (v!.isEmpty) return 'NIS harus diisi';
                if (v.length != 4) return 'NIS harus tepat 4 digit';
                return null;
              },
            ),
            const SizedBox(height: 16),

            ModernTextField(
              label: 'Kelas',
              hint: 'Contoh: XII IPA 1',
              icon: Icons.class_rounded,
              keyboardType: TextInputType.text,
              controller: _kelasController,
              validator: (v) => v!.isEmpty ? 'Kelas harus diisi' : null,
            ),
            const SizedBox(height: 20),

            // Info Kode Unik Otomatis
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.purple.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kode Unik Otomatis',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sistem akan memberikan kode unik setelah login',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            GradientButton(
              text: 'Lanjutkan ke Aspirasi',
              onPressed: _handleSiswaLogin,
              isLoading: _isLoading,
              icon: Icons.login_rounded,
            ),

            const SizedBox(height: 16),

            // 🔍 Debug: Firestore Diagnostic Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FirestoreDiagnosticScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bug_report, size: 18),
              label: const Text('🔍 Test Firestore Connection'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔑 Akun Demo Admin',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _demoText('Email: admin@sisapra.com'),
          _demoText('Password: admin123'),
        ],
      ),
    );
  }

  Widget _demoText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
