# 🔥 FIX: Firestore Security Rules - LANGSUNG KE SOLUSI

## ❌ MASALAH
Data dari app tidak masuk ke Firestore. Error: "permission-denied"

## ✅ SOLUSI (3 LANGKAH MUDAH)

---

## LANGKAH 1️⃣: Buka Firebase Console

Buka link ini di browser:
```
https://console.firebase.google.com/project/sisapraukk/firestore
```

---

## LANGKAH 2️⃣: Pergi ke Rules Tab

Lihat di bagian atas:
- ❌ Data
- ❌ Indexes
- ✅ **Rules** ← KLIK INI

Screenshot: bagian atas panel ada tab "Rules"

---

## LANGKAH 3️⃣: Copy-Paste Security Rules

Lihat current rules - pasti seperti ini:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

🔴 **Perhatian:** `if false` = SEMUA AKSES DITOLAK!

---

## LANGKAH 4️⃣: GANTI dengan Rules Ini

**Pilih SEMUA** (Ctrl+A) then paste:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow test collection untuk diagnostic
    match /_test/{document=**} {
      allow read, write: if true;
    }
    
    // Allow aspirasi collection read/write
    match /aspirasi/{document=**} {
      allow read: if true;
      allow write: if true;
    }
  }
}
```

---

## LANGKAH 5️⃣: PUBLISH

Lihat area bawah/corner → ada button **Publish**

Klik: **Publish**

Tunggu: Sampai notif "Rules published successfully"

⏱️ **PENTING:** Wait **30-60 seconds** untuk rules propagate ke semua servers

---

## LANGKAH 6️⃣: Back to App

Kembali ke browser tab dengan app running

Buka: **DevTools** (F12 → Console tab)

Clear console: (hapus old messages)

---

## LANGKAH 7️⃣: TEST

### Test A - Diagnostic:
1. Login screen ada button: "🔍 Test Firestore Connection"
2. Klik button
3. Harus show: **"✅ FIRESTORE WORKING!"** (GREEN)

Jika masih RED → rules belum propagate, tunggu lebih lama

---

### Test B - Kirim Aspirasi:
1. Login sebagai: **admin@sisapra.com** password: **admin123**
2. Or login siswa (username ada, password: admin123)
3. Go to: **Aspirasi Baru** tab
4. Isi form:
   - Kategori: pilih any
   - Judul: "Test aspirasi" (min 10 char)
   - Deskripsi: "Ini adalah test dari aplikasi flutter" (min 20 char)
5. Klik: **Kirim Aspirasi**
6. Harus show: **"✅ Aspirasi berhasil dikirim!"**

Check browser console (F12):
```
🔥 [FIRESTORE] Attempting to add aspirasi: 1707567890123
✅ [FIRESTORE] Successfully saved aspirasi: 1707567890123
```

---

## LANGKAH 8️⃣: Verify di Firebase

1. Back to: [Firebase Console Firestore](https://console.firebase.google.com/project/sisapraukk/firestore)
2. Click: **Data** tab (bukan Rules)
3. Look for collections on left:
   - ✅ **aspirasi** ← click ini
4. Should see: document dengan ID seperti "1707567890123"
5. Expand document → see fields:
   - judul: "Test aspirasi"
   - deskripsi: "Ini adalah test..."
   - nama: "Budi Santoso" or siswa name
   - kategori: "Ruang Kelas" or pilihan
   - tanggal: "2026-02-10T..."
   - status: "pending"

---

## 🎯 JIKA MASIH TIDAK KERJA

### Cek 1: Browser Console
F12 → Console tab → lihat error:
- "permission-denied" = Rules masih block
- "network error" = Firebase tidak reach
- "invalid-argument" = Data format salah

### Cek 2: Firestore Rules Status
Back to Firebase Console:
- Rules tab → check if latest rules terlihat
- Klik "Publish" lagi jika belum yakin

### Cek 3: Refresh Browser
Ctrl+Shift+R (hard refresh)

Then login lagi dan lihat console

---

## 📝 PRODUCTION RULES (Nanti)

Setelah test OK, ganti rules ini untuk security (belakangan):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /aspirasi/{aspirasi} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null;
    }
  }
}
```

---

## 🆘 STUCK?

1. **Screenshot** browser console error
2. **Share** exact error message
3. Share screenshot dari Firebase Rules tab - apa isi rules sekarang?

Dengan info itu bisa di-debug lebih lanjut.

---

## ✨ EXPECTED RESULT

Setelah follow steps:
1. ✅ Diagnostic test → GREEN
2. ✅ Submit aspirasi → Success notification
3. ✅ Firebase Console → Data visible instantly

**DONE! 🎉 Data langsung nyambu ke Firebase!**
