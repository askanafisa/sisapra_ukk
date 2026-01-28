import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Models
class User {
  final String id;
  final String nama;
  final String email;
  final String role;
  final String? NISN;
  final String? kelas;

  User({required this.id, required this.nama, required this.email, required this.role, this.kelas, this.NISN});

  Map<String, dynamic> toJson() => {'id': id, 'nama': nama, 'email': email, 'role': role, 'kelas': kelas};
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'], nama: json['nama'], email: json['email'], 
    role: json['role'], kelas: json['kelas'],
  );
}

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
  String? umpanBalik;
  String? progres;

  Aspirasi({
    required this.id, required this.userId, required this.nama, required this.kelas,
    required this.kategori, required this.judul, required this.deskripsi,
    required this.tanggal, this.status = 'pending', this.umpanBalik, this.progres,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'userId': userId, 'nama': nama, 'kelas': kelas,
    'kategori': kategori, 'judul': judul, 'deskripsi': deskripsi,
    'tanggal': tanggal.toIso8601String(), 'status': status,
    'umpanBalik': umpanBalik, 'progres': progres,
  };

  factory Aspirasi.fromJson(Map<String, dynamic> json) => Aspirasi(
    id: json['id'], userId: json['userId'], nama: json['nama'], kelas: json['kelas'],
    kategori: json['kategori'], judul: json['judul'], deskripsi: json['deskripsi'],
    tanggal: DateTime.parse(json['tanggal']), status: json['status'],
    umpanBalik: json['umpanBalik'], progres: json['progres'],
  );
}

// Data Manager
class DataManager {
  static final dummyUsers = [
    {'id': '1', 'nama': 'Admin SISAPRA', 'email': 'admin@sisapra.com', 'password': 'admin123', 'role': 'admin'},
    {'id': '2', 'nama': 'Budi Santoso', 'email': 'budi@siswa.com', 'password': 'siswa123', 'role': 'siswa', 'kelas': 'XII RPL 1'},
    {'id': '3', 'nama': 'Siti Nurhaliza', 'email': 'siti@siswa.com', 'password': 'siswa123', 'role': 'siswa', 'kelas': 'XII RPL 2'},
  ];

  static final dummyAspirasi = [
    Aspirasi(
      id: '1', userId: '2', nama: 'Budi Santoso', kelas: 'XII RPL 1',
      kategori: 'Ruang Kelas', judul: 'AC Rusak di Ruang XII RPL 1',
      deskripsi: 'AC di ruang kelas XII RPL 1 sudah tidak dingin sejak 2 minggu yang lalu',
      tanggal: DateTime(2025, 1, 10), status: 'selesai',
      umpanBalik: 'AC sudah diperbaiki oleh teknisi pada tanggal 13 Januari 2025.',
      progres: 'Selesai diperbaiki',
    ),
    Aspirasi(
      id: '2', userId: '3', nama: 'Siti Nurhaliza', kelas: 'XII RPL 2',
      kategori: 'Laboratorium', judul: 'Komputer Lab 2 Tidak Berfungsi',
      deskripsi: 'Ada 5 unit komputer di lab komputer 2 yang tidak bisa menyala',
      tanggal: DateTime(2025, 1, 12), status: 'proses',
      umpanBalik: 'Tim IT sedang mengecek komputer yang bermasalah.',
      progres: 'Dalam pengecekan',
    ),
    Aspirasi(
      id: '3', userId: '2', nama: 'Budi Santoso', kelas: 'XII RPL 1',
      kategori: 'Toilet', judul: 'Toilet Lantai 2 Bau',
      deskripsi: 'Toilet lantai 2 berbau tidak sedap dan wastafel mampet',
      tanggal: DateTime(2025, 1, 14), status: 'pending',
      progres: 'Menunggu jadwal petugas',
    ),
  ];

  // Auth
  static Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final userData = dummyUsers.firstWhere((u) => u['email'] == email && u['password'] == password);
      final user = User.fromJson(userData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
      await prefs.setBool('isLoggedIn', true);
      return user;
    } catch (e) {
      return null;
    }
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    return userJson != null ? User.fromJson(jsonDecode(userJson)) : null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Aspirasi CRUD
  static Future<List<Aspirasi>> getAspirasi() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('aspirasi');
    if (jsonStr == null) {
      await saveAspirasi(dummyAspirasi);
      return dummyAspirasi;
    }
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((json) => Aspirasi.fromJson(json)).toList();
  }

  static Future<void> saveAspirasi(List<Aspirasi> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('aspirasi', jsonEncode(list.map((a) => a.toJson()).toList()));
  }

  static Future<void> addAspirasi(Aspirasi aspirasi) async {
    final list = await getAspirasi();
    list.add(aspirasi);
    await saveAspirasi(list);
  }

  static Future<void> updateAspirasi(Aspirasi updated) async {
    final list = await getAspirasi();
    final index = list.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      list[index] = updated;
      await saveAspirasi(list);
    }
  }

  static String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}