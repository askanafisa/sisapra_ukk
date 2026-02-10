import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// ============================================================================
// USER MODEL
// ============================================================================
class User {
  final String id;
  final String nama;
  final String email;
  final String role;
  final String? kelas;

  User({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.kelas,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'email': email,
        'role': role,
        'kelas': kelas,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        nama: json['nama'],
        email: json['email'],
        role: json['role'],
        kelas: json['kelas'],
      );
}

// ============================================================================
// ASPIRASI MODEL
// ============================================================================
class Aspirasi {
  final String id;
  final String userId;
  final String nama;
  final String kelas;
  final String kategori;
  final String judul;
  final String deskripsi;
  final DateTime tanggal;
  String status;
  String progres;
  String? umpanBalik;

  Aspirasi({
    required this.id,
    required this.userId,
    required this.nama,
    required this.kelas,
    required this.kategori,
    required this.judul,
    required this.deskripsi,
    required this.tanggal,
    this.status = 'pending',
    this.progres = 'Menunggu review admin',
    this.umpanBalik,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'nama': nama,
        'kelas': kelas,
        'kategori': kategori,
        'judul': judul,
        'deskripsi': deskripsi,
        'tanggal': tanggal.toIso8601String(),
        'status': status,
        'progres': progres,
        'umpanBalik': umpanBalik,
      };

  factory Aspirasi.fromJson(Map<String, dynamic> json) => Aspirasi(
        id: json['id'],
        userId: json['userId'],
        nama: json['nama'],
        kelas: json['kelas'],
        kategori: json['kategori'],
        judul: json['judul'],
        deskripsi: json['deskripsi'],
        tanggal: DateTime.parse(json['tanggal']),
        status: json['status'] ?? 'pending',
        progres: json['progres'] ?? 'Menunggu review admin',
        umpanBalik: json['umpanBalik'],
      );

  // ✅ TAMBAH METHOD COPYWITH UNTUK CRUD
  Aspirasi copyWith({
    String? id,
    String? userId,
    String? nama,
    String? kelas,
    String? kategori,
    String? judul,
    String? deskripsi,
    DateTime? tanggal,
    String? status,
    String? progres,
    String? umpanBalik,
  }) {
    return Aspirasi(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      kelas: kelas ?? this.kelas,
      kategori: kategori ?? this.kategori,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      tanggal: tanggal ?? this.tanggal,
      status: status ?? this.status,
      progres: progres ?? this.progres,
      umpanBalik: umpanBalik ?? this.umpanBalik,
    );
  }
}

// ============================================================================
// DATA MANAGER DENGAN CRUD LENGKAP
// ============================================================================
class DataManager {
  static final List<User> dummyUsers = [
    User(
      id: 'admin1',
      nama: 'Admin Sekolah',
      email: 'admin@sisapra.com',
      role: 'admin',
    ),
    User(
      id: 'siswa1',
      nama: 'Budi Santoso',
      email: 'budi@siswa.com',
      role: 'siswa',
      kelas: 'XII RPL 1',
    ),
    User(
      id: 'siswa2',
      nama: 'Siti Aminah',
      email: 'siti@siswa.com',
      role: 'siswa',
      kelas: 'XII RPL 2',
    ),
  ];

  // LOGIN
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final user = dummyUsers.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('Email tidak ditemukan'),
      );

      // 🔑 PASSWORD ADMIN & DEMO = admin123
      if (password != 'admin123') {
        throw Exception('Password salah');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));

      return {
        'success': true,
        'user': user,
        'message': 'Login berhasil',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // GET CURRENT USER
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('user');
      if (json == null) return null;
      return User.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  // GET ASPIRASI
  static Future<List<Aspirasi>> getAspirasi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('aspirasi') ?? '[]';
      final List data = jsonDecode(jsonStr);
      return data.map((e) => Aspirasi.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // ADD ASPIRASI
  static Future<void> addAspirasi(Aspirasi aspirasi) async {
    // Validasi input
    if (aspirasi.judul.isEmpty || aspirasi.deskripsi.isEmpty) {
      throw Exception('Judul dan deskripsi harus diisi');
    }

    final list = await getAspirasi();
    list.add(aspirasi);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'aspirasi',
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  // UPDATE ASPIRASI
  static Future<void> updateAspirasi(Aspirasi updated) async {
    final list = await getAspirasi();
    final index = list.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;

    list[index] = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'aspirasi',
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  // ✅ TAMBAH: EDIT ASPIRASI UNTUK SISWA
  static Future<bool> editAspirasi(Aspirasi updated) async {
    try {
      final list = await getAspirasi();
      final index = list.indexWhere((a) => a.id == updated.id);

      if (index == -1) return false;

      // Pastikan hanya data tertentu yang bisa diubah oleh siswa
      list[index] = list[index].copyWith(
        judul: updated.judul,
        deskripsi: updated.deskripsi,
        kategori: updated.kategori,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'aspirasi',
        jsonEncode(list.map((e) => e.toJson()).toList()),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ✅ TAMBAH: DELETE ASPIRASI
  static Future<bool> deleteAspirasi(String id) async {
    try {
      final list = await getAspirasi();
      
      // Validasi apakah data exist
      if (!list.any((a) => a.id == id)) {
        return false; // Data tidak ditemukan
      }
      
      list.removeWhere((a) => a.id == id);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'aspirasi',
        jsonEncode(list.map((e) => e.toJson()).toList()),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

// ============================================================================
// HELPERS, CONSTANTS, COLORS
// ============================================================================
class Helpers {
  static String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'diproses':
        return Icons.refresh;
      case 'selesai':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}

class AppConstants {
  static const String appName = 'ASPIRASI SARANA';
}

class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF8B5CF6);

  static Gradient? get primaryGradient => null;
}