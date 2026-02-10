import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../app/data.dart' hide Helpers, AppColors, AppConstants;
import '../widgets/common_widgets.dart';

/// Tab Form untuk mengirim aspirasi baru
class SiswaFormTab extends StatefulWidget {
  final User? user;
  final VoidCallback? onSubmitted;
  
  const SiswaFormTab({
    super.key,
    this.user,
    this.onSubmitted,
  });

  @override
  State<SiswaFormTab> createState() => _SiswaFormTabState();
}

class _SiswaFormTabState extends State<SiswaFormTab> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String? _selectedKategori; 
  bool _isSubmitting = false;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || widget.user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final aspirasi = Aspirasi(
        id: DataManager.generateId(),
        userId: widget.user!.id,
        nama: widget.user!.nama,
        kelas: widget.user!.kelas ?? '',
        kategori: _selectedKategori!,
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        tanggal: DateTime.now(),
        status: 'pending',           // 👈 Sesuai dengan data.dart
        progres: 'Menunggu review admin',
      );

      await DataManager.addAspirasi(aspirasi);

      if (mounted) {
        // Reset form
        setState(() {
          _isSubmitting = false;
          _selectedKategori = null;
          _judulController.clear();
          _deskripsiController.clear();
        });
        
        // Tampilkan notifikasi sukses
        Helpers.showSnackBar(context, '✅ Aspirasi berhasil dikirim!');
        
        // Reset form state
        _formKey.currentState!.reset();
        
        // Trigger callback untuk pindah ke tab histori
        widget.onSubmitted?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Helpers.showSnackBar(
          context,
          '❌ Gagal mengirim aspirasi: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.info.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05)
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_rounded,
                      color: AppColors.info, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sampaikan keluhan atau saran tentang fasilitas sekolah',
                      style: TextStyle(color: AppColors.info, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Dropdown Kategori
            DropdownButtonFormField<String>(
              value: _selectedKategori,
              decoration: const InputDecoration(
                labelText: 'Kategori Sarana',
                prefixIcon: Icon(Icons.category_rounded),
              ),
              items: AppConstants.kategoris
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedKategori = v),
              validator: (v) => v == null ? 'Pilih kategori' : null,
            ),
            const SizedBox(height: 20),
            
            // Input Judul
            ModernTextField(
              label: 'Judul',
              hint: 'Ringkasan masalah',
              icon: Icons.title_rounded,
              controller: _judulController,
              maxLength: 100,
              validator: (v) => v!.isEmpty
                  ? 'Judul harus diisi'
                  : v.length < 10
                      ? 'Minimal 10 karakter'
                      : null,
            ),
            const SizedBox(height: 20),
            
            // Input Deskripsi
            ModernTextField(
              label: 'Deskripsi',
              hint: 'Jelaskan detail masalahnya',
              icon: Icons.description_rounded,
              controller: _deskripsiController,
              maxLines: 6,
              maxLength: 500,
              validator: (v) => v!.isEmpty
                  ? 'Deskripsi harus diisi'
                  : v.length < 20
                      ? 'Minimal 20 karakter'
                      : null,
            ),
            const SizedBox(height: 32),
            
            // Tombol Submit
            GradientButton(
              text: 'Kirim Aspirasi',
              icon: Icons.send_rounded,
              onPressed: _submit,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}