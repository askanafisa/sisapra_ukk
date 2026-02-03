import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
        status: json['status'],
        progres: json['progres'],
        umpanBalik: json['umpanBalik'],
      );
}

class DataManager {
  static final List<Aspirasi> dummyAspirasi = [];

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('user');
    return json == null ? null : User.fromJson(jsonDecode(json));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<List<Aspirasi>> getAspirasi() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('aspirasi');

    if (jsonStr == null) {
      await prefs.setString('aspirasi', jsonEncode([]));
      return [];
    }

    final List data = jsonDecode(jsonStr);
    return data.map((e) => Aspirasi.fromJson(e)).toList();
  }

  static Future<void> addAspirasi(Aspirasi aspirasi) async {
    final list = await getAspirasi();
    list.add(aspirasi);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'aspirasi',
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  static String generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  static Future<void> updateAspirasi(Aspirasi aspirasi) async {}

  static Future<dynamic> login(String trim, String text) async {}
}
