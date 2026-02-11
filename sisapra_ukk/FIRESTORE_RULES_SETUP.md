# 🔧 Setup Firestore Security Rules

**ISSUE:** Data tidak masuk ke Firestore karena permission denied

---

## ✅ Solusi: Update Security Rules

### Via Firebase Console:

1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project: **sisapraukk**
3. Go to **Firestore Database** → **Rules** tab
4. Replace dengan code ini:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Collections: aspirasi
    match /aspirasi/{document=**} {
      // Anyone can read
      allow read: if true;
      
      // Anyone can write (for testing)
      // TODO: Change to require auth in production
      allow write: if true;
    }
    
    // Add more collections here as needed
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

5. Click **Publish**
6. Wait ~30 seconds for rules to propagate
7. Try kirim aspirasi lagi

---

## 🔒 Production Rules (With Auth)

Once you implement Firebase Auth, use:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Aspirasi: users dapat read/write own data
    match /aspirasi/{aspirasi} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && 
                               request.resource.data.userId == request.auth.uid;
    }
    
  }
}
```

---

## 🧪 Testing:

1. ✅ Set **permissive rules** (allow write: if true)
2. ✅ Kirim aspirasi dari app
3. ✅ Check Firebase Console → Firestore → aspirasi collection
4. ✅ Verify dokumen muncul dengan benar
5. ✅ Once working, update ke **production rules** with auth

---

## 📌 Current Status:

- **Project ID:** sisapraukk
- **Collection:** aspirasi
- **Auth:** Custom login (SharedPreferences) - not Firebase Auth
- **Security:** Need permissive rules for testing

---

## ❓ If Data Still Doesn't Appear:

Check browser console (F12) for errors:
- Look for: `permission-denied`
- Look for: `quota exceeded`
- Look for: `network error`

Then share in Discord/email the exact error message.
