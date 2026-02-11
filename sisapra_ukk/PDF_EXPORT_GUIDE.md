# 📄 Fitur PDF Export/Laporan - PANDUAN ADMIN

## ✨ Fitur Baru: Generate PDF Report

Admin sekarang bisa **export data aspirasi ke PDF** dengan tampilan profesional!

---

## 🎯 Cara Menggunakan

### STEP 1: Login sebagai Admin
```
Email: admin@sisapra.com
Password: admin123
```

### STEP 2: Buka Admin Screen
Setelah login → otomatis ke Admin Screen

### STEP 3: (Optional) Filter Data
- Search aspirasi
- atau gunakan filter: Tanggal, Bulan, Siswa, Kategori
- untuk data yang spesifik

### STEP 4: Klik Button "Generate PDF Report"
Tombol ada di bawah filter controls
- Icon: 📄 (PDF icon)
- Warna: Deep Purple
- Text: "Generate PDF Report"

### STEP 5: Preview & Download/Print
Akan membuka screen baru dengan:
- Preview PDF full page
- 2 action buttons:
  - **📥 Download:** Download PDF ke file
  - **🖨️ Print:** Langsung ke printer

---

## 📋 Isi PDF Report

### 1. HEADER
```
SISAPRA - Sistem Informasi Sarana Prasarana
Laporan Data Aspirasi Siswa
Tanggal Generate: 10 Feb 2026
```

### 2. RINGKASAN STATISTIK (📊)
Menampilkan 5 stat box:
- Total Aspirasi (warna biru)
- Menunggu (warna orange)
- Diproses (warna biru muda)
- Selesai (warna hijau)
- Ditolak (warna merah)

### 3. BREAKDOWN KATEGORI (🏷️)
Tabel dengan 2 kolom:
- Kategori: nama kategori (Ruang Kelas, Laboratorium, dll)
- Jumlah: berapa aspirasi per kategori

### 4. DETAIL ASPIRASI (📝)
Tabel lengkap dengan kolom:
- No: nomor urut
- Nama Siswa: nama lengkap
- Judul Aspirasi: judul aspirasi
- Kategori: kategori
- Status: status (Menunggu/Diproses/Selesai/Ditolak)
- Tanggal: tanggal submit

### 5. FOOTER
```
Halaman 1 dari 3 | © 2026 SISAPRA - Sekolah
```

---

## 🎨 Design PDF

✅ **Profesional & Menarik:**
- Header dengan gradient color
- Stat boxes dengan border warna
- Tabel dengan alternating row colors
- Icon emoji untuk visual clarity
- Font readable (konsisten dengan brand)
- Multi-page support (jika data banyak)

✅ **Responsive:**
- A4 format dengan margin 40px
- Column width proportional
- Text size optimal untuk print
- Page break otomatis

---

## 🔧 Fitur Download/Print

### Download PDF
- Klik button 📥 di toolbar
- Browser akan prompt save dialog
- Nama file: `Laporan_Aspirasi_2026-02-10.pdf`
- Format: A4 landscape optimal

### Print ke Printer
- Klik button 🖨️ di toolbar
- Native print dialog muncul
- Pilih printer
- Adjust settings (jumlah halaman, quality, dll)
- Klik Print

---

## 📱 ComboBox Filter + Export

**CONTOH USE CASE:**

Admin ingin laporan aspirasi Kategori "Ruang Kelas" yang status "Menunggu":

```
1. Go to: Kategori dropdown → pilih "Ruang Kelas"
2. Go to: Status... (tunggu, belum ada statusnya di filter)
   atau cari manual dengan search
3. Klik: "Generate PDF Report"
4. PDF muncul dengan **HANYA** data filtered
5. Klik: Download atau Print
```

---

## 🎓 Contoh Output PDF

```
═══════════════════════════════════════════════════════════════════

        SISAPRA - Sistem Informasi Sarana Prasarana
              Laporan Data Aspirasi Siswa
                      10 Feb 2026

═══════════════════════════════════════════════════════════════════

LAPORAN ASPIRASI SISWA
Filter: Kategori: Ruang Kelas

───────────────────────────────────────────────────────────────────
📊 RINGKASAN DATA

┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│     15       │ │      8       │ │      4       │ │      2       │
│ Total        │ │ Menunggu ⏳  │ │ Diproses 🔄  │ │ Selesai ✅   │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘

───────────────────────────────────────────────────────────────────
🏷️ BREAKDOWN PER KATEGORI

│ Kategori          │ Jumlah │
├───────────────────┼────────┤
│ Ruang Kelas       │   15   │
│ Laboratorium      │    8   │
│ Toilet            │    5   │
│ Perpustakaan      │    3   │

───────────────────────────────────────────────────────────────────
📝 DETAIL ASPIRASI

│ No │ Nama Siswa      │ Judul Aspirasi           │ Kategori     │ Status    │ Tanggal    │
├────┼─────────────────┼──────────────────────────┼──────────────┼───────────┼────────────┤
│ 1  │ Budi Santoso    │ AC Rusak dan Tidak Dingin│ Ruang Kelas  │ ⏳ Menunggu │ 10 Feb 2026│
│ 2  │ Siti Aminah     │ Lampu Flickering         │ Ruang Kelas  │ 🔄 Diproses│ 09 Feb 2026│
│ 3  │ Ahmad Wijaya    │ Kursi Rusak              │ Ruang Kelas  │ ✅ Selesai │ 08 Feb 2026│

═════════════════════════════════════════════════════════════════════
                    Halaman 1 dari 2
           © 2026 SISAPRA - Sistem Aspirasi Sekolah
═════════════════════════════════════════════════════════════════════
```

---

## 🚀 Performance Tips

- **Besar Data:** Jika aspirasi > 100, PDF bisa loading lambat (normal, karena generate table besar)
- **Print Quality:** Gunakan printer dengan dpi tinggi untuk best result
- **File Size:** Ukuran PDF ~300KB typical
- **Multi-page:** Otomatis page break jika data banyak

---

## ❓ FAQ

**Q: Tombol PDF Report tidak muncul?**
A: Hanya muncul jika ada data. Apply filter dulu atau pastikan ada data aspirasi.

**Q: PDF tidak bisa download?**
A: Browser mungkin block. Check popup blocker / console untuk error.

**Q: Print preview blank/error?**
A: Refresh page atau reload app, sometimes cache issue.

**Q: Bisa custom report format?**
A: Ya, edit file `aspirasi_pdf_export.dart` untuk customize layout/warna/font.

---

## 🔮 Future Enhancement

- [ ] Add chart/graph untuk statistik visual
- [ ] Custom date range untuk filter
- [ ] Status filter di UI (belum ada sekarang)
- [ ] Export ke Excel/CSV (tambahan format)
- [ ] Email PDF langsung ke admin
- [ ] Signature/approval section

---

## 📞 Support

Jika ada bug atau feature request:
1. Check console (F12) untuk error message
2. Screenshot UI dan PDF preview
3. Share detail langkah-langkah yang dijalankan

**HAPPY REPORTING! 🎉**
