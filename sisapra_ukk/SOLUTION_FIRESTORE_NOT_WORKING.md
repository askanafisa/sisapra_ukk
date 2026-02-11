# 🚀 Action Plan: Fix Firestore Data Not Showing

## Problem Diagnosis

Data tidak muncul di Firestore kemungkinan karena:
1. ❌ **Firestore Security Rules** terlalu ketat (default: deny write)
2. ❌ Firestore database belum initialized
3. ❌ Network/permission error

---

## ✅ Solution Steps

### STEP 1: Test Connection
```
1. Reload browser (app sudah running di Chrome)
2. Click "🔍 Test Firestore Connection" button di login screen
3. Baca hasil test - akan show:
   ✅ If working: "FIRESTORE WORKING!"
   ❌ If error: specific error message
```

### STEP 2: Update Firestore Security Rules
**IF TEST SHOWS PERMISSION DENIED ERROR:**

```
1. Open: https://console.firebase.google.com/project/sisapraukk/firestore
2. Go to: Firestore Database → Rules tab
3. Replace entire rules dengan:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /aspirasi/{document=**} {
      allow read, write: if true;
    }
  }
}
```

4. Click: Publish button
5. Wait: 30 seconds
6. Refresh: Browser
7. Re-test: Click diagnostic button again
```

### STEP 3: Try Submit Aspirasi
```
1. Login sebagai siswa
2. Go to: Aspirasi Baru tab
3. Fill: Kategori, Judul (min 10 char), Deskripsi (min 20 char)
4. Click: Kirim Aspirasi
5. Should see: "✅ Aspirasi berhasil dikirim!"
```

### STEP 4: Verify di Firebase
```
1. Open: Firebase Console
2. Click: Firestore Database
3. Check: aspirasi collection
4. Should see: document dengan ID = timestamp
5. Fields: judul, deskripsi, nama, kategori, tanggal, status, etc
```

---

## 🧪 What The Test Button Does

```dart
✅ Test 1: Access FirebaseFirestore.instance
✅ Test 2: Create collection reference  
✅ Test 3: Read from collection (non-destructive)
✅ Test 4: Write test document (verifies permission)
✅ Test 5: Clean up test document
```

If any step fails → shows specific error message

---

## 📋 Current App Setup

| Item | Value |
|------|-------|
| Firebase Project | sisapraukk |
| Region | (auto) |
| Firestore Status | Initialized ✅ |
| Authentication | Custom login (SharedPreferences) |
| Collection | aspirasi |
| Debug Logging | Enabled (check console) |

---

## 🔍 Browser Console Debug Output

When you submit aspirasi, check browser console (F12) for:

```
🔥 [FIRESTORE] Attempting to add aspirasi: 1707567890123
🔥 [FIRESTORE] Data to save: {id: "1707567890123", ...}
✅ [FIRESTORE] Successfully saved aspirasi: 1707567890123
```

Or if error:
```
❌ [FIRESTORE] Error: [firestore/permission-denied] Missing or insufficient permissions.
💾 [LOCAL] Falling back to SharedPreferences
✅ [LOCAL] Saved to SharedPreferences
```

---

## ⚠️ If Still Not Working

1. Check browser DevTools Console (F12 → Console tab)
2. Look for red error messages
3. Share exact error message
4. Verify Firebase project credentials in `firebase_options.dart`
5. Check if Firestore database exists in Firebase Console

---

## 📝 Notes

- **Testing** uses permissive rules: `allow read, write: if true`
- **Production** should require authentication
- **Local fallback** ensures app works even if Firestore errors
- **Logging** helps debug what's happening behind scenes
