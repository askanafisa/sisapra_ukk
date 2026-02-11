import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    // Try Firestore first
    try {
      print('🔥 [FIRESTORE] Fetching aspirasi...');
      final coll = FirebaseFirestore.instance.collection('aspirasi');
      final snapshot = await coll.orderBy('tanggal', descending: true).get();
      print('✅ [FIRESTORE] Found ${snapshot.docs.length} documents');
      return snapshot.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());

        // Normalize tanggal: allow Timestamp or String
        final t = data['tanggal'];
        if (t is Timestamp) {
          data['tanggal'] = t.toDate().toIso8601String();
        } else if (t is DateTime) {
          data['tanggal'] = t.toIso8601String();
        } else if (t == null) {
          data['tanggal'] = DateTime.now().toIso8601String();
        }

        // Ensure id is present
        data['id'] = data['id'] ?? d.id;

        return Aspirasi.fromJson(data);
      }).toList();
    } catch (e) {
      // Fallback to local storage
      print('❌ [FIRESTORE] Error: $e');
      print('💾 [LOCAL] Falling back to SharedPreferences');
      try {
        final prefs = await SharedPreferences.getInstance();
        final jsonStr = prefs.getString('aspirasi') ?? '[]';
        final List data = jsonDecode(jsonStr);
        print('✅ [LOCAL] Found ${data.length} local aspirasi');
        return data.map((e) => Aspirasi.fromJson(e)).toList();
      } catch (e) {
        print('❌ [LOCAL] Error: $e');
        return [];
      }
    }
  }

  // ADD ASPIRASI
  static Future<void> addAspirasi(Aspirasi aspirasi) async {
    // Validasi input
    if (aspirasi.judul.isEmpty || aspirasi.deskripsi.isEmpty) {
      throw Exception('Judul dan deskripsi harus diisi');
    }
    // Try to write to Firestore
    try {
      print('🔥 [FIRESTORE] Attempting to add aspirasi: ${aspirasi.id}');
      final coll = FirebaseFirestore.instance.collection('aspirasi');
      final docRef = coll.doc(aspirasi.id);
      final data = aspirasi.toJson();
      // Store tanggal as Timestamp for Firestore
      data['tanggal'] = Timestamp.fromDate(aspirasi.tanggal);
      print('🔥 [FIRESTORE] Data to save: $data');
      await docRef.set(data);
      print('✅ [FIRESTORE] Successfully saved aspirasi: ${aspirasi.id}');
      return;
    } catch (e) {
      // Fallback to local storage
      print('❌ [FIRESTORE] Error: $e');
      print('💾 [LOCAL] Falling back to SharedPreferences');
      final list = await getAspirasi();
      list.add(aspirasi);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'aspirasi',
        jsonEncode(list.map((e) => e.toJson()).toList()),
      );
      print('✅ [LOCAL] Saved to SharedPreferences');
    }
  }

  // UPDATE ASPIRASI
  static Future<void> updateAspirasi(Aspirasi updated) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('aspirasi').doc(updated.id);
      final data = updated.toJson();
      data['tanggal'] = Timestamp.fromDate(updated.tanggal);
      await docRef.set(data, SetOptions(merge: true));
      return;
    } catch (_) {
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
  }

  // ✅ TAMBAH: EDIT ASPIRASI UNTUK SISWA
  static Future<bool> editAspirasi(Aspirasi updated) async {
    try {
      // Try update in Firestore
      final docRef =
          FirebaseFirestore.instance.collection('aspirasi').doc(updated.id);
      final snapshot = await docRef.get();
      if (!snapshot.exists) return false;

      await docRef.update({
        'judul': updated.judul,
        'deskripsi': updated.deskripsi,
        'kategori': updated.kategori,
      });
      return true;
    } catch (_) {
      // Fallback to local
      try {
        final list = await getAspirasi();
        final index = list.indexWhere((a) => a.id == updated.id);

        if (index == -1) return false;

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
  }

  // ✅ TAMBAH: DELETE ASPIRASI
  static Future<bool> deleteAspirasi(String id) async {
    try {
      // Try Firestore delete
      final docRef = FirebaseFirestore.instance.collection('aspirasi').doc(id);
      final snapshot = await docRef.get();
      if (!snapshot.exists) return false;
      await docRef.delete();
      return true;
    } catch (_) {
      // Fallback to local
      try {
        final list = await getAspirasi();
        if (!list.any((a) => a.id == id)) return false;
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
  }

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

// ============================================================================
// HELPERS, CONSTANTS, COLORS
// ============================================================================
// Helpers, AppConstants and AppColors are defined in lib/app/theme.dart
// to keep them centralized. Keep this file focused on models and data.
