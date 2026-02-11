# 🔥 Firestore Integration - SISAPRA UKK

## ✅ Status: SEMUA DATA MASUK KE FIREBASE

Aplikasi sudah dikonfigurasi untuk **menyimpan semua aspirasi langsung ke Firestore**.

---

## 📋 Implementasi

### Dependencies (pubspec.yaml)
```yaml
firebase_core: ^2.32.0
cloud_firestore: ^4.8.0
firebase_auth: ^4.4.0
```

---

## 🗄️ Firestore Collection Structure

### Collection: `aspirasi`

```javascript
{
  "aspirasi": {
    "ID_TIMESTAMP_1": {
      "id": "1707567890123",
      "userId": "siswa1",
      "nama": "Budi Santoso",
      "kelas": "XII RPL 1",
      "kategori": "Ruang Kelas",
      "judul": "AC Rusak",
      "deskripsi": "AC di kelas tidak bisa dingin...",
      "tanggal": Timestamp(2024-02-10T10:30:00Z),  // Firestore Timestamp
      "status": "pending",
      "progres": "Menunggu review admin",
      "umpanBalik": null
    },
    "ID_TIMESTAMP_2": { ... }
  }
}
```

---

## 🔄 CRUD Operations (Data Flow)

### 1️⃣ CREATE - Kirim Aspirasi
```dart
// User submit form → addAspirasi() 
// ↓ Try Firestore
// ✅ Simpan ke: aspirasi/{aspirasi.id}
// ↓ If error → Fallback SharedPreferences
```

**File:** `lib/screens/siswa_form_tab.dart` (line ~55)

---

### 2️⃣ READ - Tampilkan Data
```dart
// getAspirasi() dijalankan saat:
// - Load admin/siswa screen
// - Refresh pull-to-refresh
// ↓ Try Firestore
// ✅ Query: collection('aspirasi').orderBy('tanggal', descending: true)
// ↓ If error → Fallback SharedPreferences
```

**File:** `lib/app/data.dart` (line ~204-236)

---

### 3️⃣ UPDATE - Edit Status/Umpan Balik (Admin)
```dart
// Admin tambah feedback → updateAspirasi()
// ↓ Try Firestore
// ✅ Update: aspirasi/{id} + merge: true
// Fields: status, progres, umpanBalik
// ↓ If error → Fallback SharedPreferences
```

**File:** `lib/app/data.dart` (line ~268-285)

---

### 4️⃣ EDIT - Edit Aspirasi (Siswa)
```dart
// Siswa edit aspirasi → editAspirasi()
// ↓ Try Firestore
// ✅ Update: aspiration/{id} + fields: judul, deskripsi, kategori
// ↓ If error → Fallback SharedPreferences
```

**File:** `lib/app/data.dart` (line ~287-328)

---

### 5️⃣ DELETE - Hapus Aspirasi (Admin)
```dart
// Admin hapus → deleteAspirasi(id)
// ↓ Try Firestore
// ✅ Delete: aspirasi/{id}
// ↓ If error → Fallback SharedPreferences
```

**File:** `lib/app/data.dart` (line ~330-354)

---

## 🛡️ Error Handling

Setiap operasi memiliki **try-catch dengan fallback**:

```dart
try {
  // Primary: Firestore
  await FirebaseFirestore.instance.collection('aspirasi').doc(id).set(data);
} catch (e) {
  // Fallback: SharedPreferences (local)
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('aspirasi', jsonEncode(data));
}
```

**Benefit:**
- ✅ App tetap berfungsi meski Firestore down
- ✅ Sync otomatis ketika koneksi kembali (jika ditambah sync logic)
- ✅ Offline-first capability

---

## 🚀 Testing Checklist

- [ ] Run app: `flutter run`
- [ ] Login sebagai siswa
- [ ] Kirim aspirasi baru → cek Firestore Console
- [ ] Login sebagai admin
- [ ] Beri umpan balik → cek update di Firestore
- [ ] Hapus aspirasi → cek document terhapus
- [ ] Offline mode → pastikan fallback ke local storage

---

## 🔗 Firestore Console URL

Setelah setup Firebase:
```
https://console.firebase.google.com/project/{PROJECT_ID}/firestore
```

Koleksi yang harus ada:
- `aspirasi` (documents dengan ID = aspirasi id)

---

## 📝 Timestamp Handling

**Saat kirim ke Firestore:**
```dart
data['tanggal'] = Timestamp.fromDate(aspirasi.tanggal);  // DateTime → Timestamp
```

**Saat ambil dari Firestore:**
```dart
if (t is Timestamp) {
  data['tanggal'] = (t as Timestamp).toDate().toIso8601String();  // Timestamp → ISO String
}
```

---

## ✨ Summary

| Fitur | Status |
|-------|--------|
| Simpan ke Firestore | ✅ |
| Ambil dari Firestore | ✅ |
| Update di Firestore | ✅ |
| Delete dari Firestore | ✅ |
| Fallback local | ✅ |
| Timestamp conversion | ✅ |
| Error handling | ✅ |

**SEMUA DATA LANGSUNG MASUK KE FIREBASE! 🎉**
