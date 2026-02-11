import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../app/data.dart';
import '../widgets/common_widgets.dart';

// ============================================================================
// SISWA HISTORI TAB - RIWAYAT ASPIRASI DENGAN FITUR SEARCH
// ============================================================================
//
// ✅ FITUR BARU YANG DITAMBAHKAN:
// 1. Search bar untuk cari aspirasi (judul, kategori, deskripsi)
// 2. Highlight text yang match dengan query pencarian
// 3. Sort otomatis berdasarkan relevansi
// 4. Empty state khusus untuk hasil pencarian
//
// ✅ FITUR LAMA YANG TETAP ADA:
// - Edit aspirasi (jika status pending)
// - Hapus aspirasi (jika status pending)
// - Lihat detail aspirasi
// - Refresh data
//
// CARA KERJA SEARCH:
// 1. User ketik di search bar
// 2. Sistem tunggu 500ms (debouncing)
// 3. Filter aspirasi berdasarkan query
// 4. Tampilkan hasil dengan highlight
//
// ============================================================================

/// Tab Histori untuk melihat semua aspirasi yang pernah dikirim
class SiswaHistoriTab extends StatefulWidget {
  final String? userId;

  const SiswaHistoriTab({
    super.key,
    this.userId,
  });

  @override
  State<SiswaHistoriTab> createState() => SiswaHistoriTabState();
}

class SiswaHistoriTabState extends State<SiswaHistoriTab> {
  List<Aspirasi> _aspirasi = [];
  List<Aspirasi> _filteredAspirasi = []; // ✅ TAMBAH: untuk hasil filter
  bool _isLoading = true;

  // ========================================
  // ✅ TAMBAH: Variabel untuk SEARCH
  // ========================================
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // Query pencarian

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose(); // ✅ TAMBAH
    super.dispose();
  }

  /// Memuat data aspirasi dari database (AMAN dari userId null)
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final all = await DataManager.getAspirasi();
    if (!mounted) return;

    setState(() {
      if (widget.userId == null) {
        _aspirasi = [];
      } else {
        _aspirasi = all.where((a) => a.userId == widget.userId).toList()
          ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
      }
      _applyFilter(); // ✅ TAMBAH: Apply filter setelah load data
      _isLoading = false;
    });
  }

  // ========================================
  // ✅ TAMBAH: Fungsi Filter
  // ========================================
  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredAspirasi = _aspirasi;
      return;
    }

    final query = _searchQuery.toLowerCase();
    _filteredAspirasi = _aspirasi.where((a) {
      final judul = a.judul.toLowerCase();
      final kategori = a.kategori.toLowerCase();
      final deskripsi = a.deskripsi.toLowerCase();

      return judul.contains(query) ||
          kategori.contains(query) ||
          deskripsi.contains(query);
    }).toList();

    // Sort berdasarkan relevansi
    _filteredAspirasi.sort((a, b) {
      final judulA = a.judul.toLowerCase();
      final judulB = b.judul.toLowerCase();

      final aStartsWith = judulA.startsWith(query);
      final bStartsWith = judulB.startsWith(query);

      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;
      return b.tanggal.compareTo(a.tanggal);
    });
  }

  // ========================================
  // ✅ TAMBAH: Fungsi Highlight
  // ========================================
  List<TextSpan> _highlightText(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final spans = <TextSpan>[];
    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase();

    int start = 0;
    int indexOfMatch;

    while ((indexOfMatch = textLower.indexOf(queryLower, start)) != -1) {
      if (indexOfMatch > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
      }

      spans.add(TextSpan(
        text: text.substring(indexOfMatch, indexOfMatch + query.length),
        style: TextStyle(
          color: AppColors.primary,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          fontWeight: FontWeight.bold,
        ),
      ));

      start = indexOfMatch + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  /// Method publik agar bisa direfresh dari luar (dipanggil dari SiswaScreen)
  void refresh() => _loadData();

  // Form Edit untuk Siswa
  void _showEditForm(Aspirasi aspirasi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _EditAspirasiForm(
        aspirasi: aspirasi,
        onSaved: () {
          _loadData();
          Navigator.pop(context);
          Helpers.showSnackBar(context, '✅ Aspirasi berhasil diperbarui!');
        },
      ),
    );
  }

  // Konfirmasi Hapus untuk Siswa
  Future<void> _confirmDelete(Aspirasi aspirasi) async {
    if (aspirasi.status.toLowerCase() != 'pending') {
      Helpers.showSnackBar(
        context,
        '❌ Hanya bisa menghapus aspirasi dengan status PENDING',
        isError: true,
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus aspirasi "${aspirasi.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await DataManager.deleteAspirasi(aspirasi.id);

      if (success) {
        await _loadData();
        Helpers.showSnackBar(context, '✅ Aspirasi berhasil dihapus!');
      } else {
        Helpers.showSnackBar(context, '❌ Gagal menghapus aspirasi',
            isError: true);
      }
    }
  }

  // ========================================
  // ✅ TAMBAH: Widget Search Bar
  // ========================================
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          // Debouncing
          Future.delayed(const Duration(milliseconds: 500), () {
            if (value == _searchController.text) {
              setState(() {
                _searchQuery = value;
                _applyFilter();
              });
            }
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari judul, kategori, deskripsi...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _applyFilter();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark 
              ? Colors.black.withOpacity(0.25)
              : Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // ✅ TAMBAH: Search Bar
        _buildSearchBar(),

        // ✅ TAMBAH: Info hasil pencarian
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Ditemukan ${_filteredAspirasi.length} aspirasi',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _applyFilter();
                    });
                  },
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ),

        // List aspirasi
        Expanded(
          child: _filteredAspirasi.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off // ✅ TAMBAH: Icon khusus search
                              : Icons.inbox_rounded,
                          size: 100,
                          color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        widget.userId == null
                            ? 'Memuat data siswa...'
                            : _searchQuery.isNotEmpty
                                ? 'Tidak ada hasil untuk "$_searchQuery"' // ✅ TAMBAH
                                : 'Belum ada aspirasi',
                        style: TextStyle(
                            fontSize: 16, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      // ✅ TAMBAH: Tombol reset search
                      if (_searchQuery.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _applyFilter();
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset Pencarian'),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredAspirasi.length,
                    itemBuilder: (context, i) {
                      // ✅ EDIT: Gunakan card dengan highlight jika ada search
                      if (_searchQuery.isNotEmpty) {
                        return _buildCardWithHighlight(_filteredAspirasi[i]);
                      }
                      return AspirasiCard(
                        aspirasi: _filteredAspirasi[i],
                        showUser: false,
                        showMenu: true,
                        onTap: () => _showDetail(_filteredAspirasi[i]),
                        onEdit: () => _showEditForm(_filteredAspirasi[i]),
                        onDelete: () => _confirmDelete(_filteredAspirasi[i]),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // ========================================
  // ✅ TAMBAH: Card dengan Highlight
  // ========================================
  Widget _buildCardWithHighlight(Aspirasi a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetail(a),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: _highlightText(a.judul, _searchQuery),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  StatusBadge(status: a.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.category,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: _highlightText(a.kategori, _searchQuery),
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: _highlightText(
                    a.deskripsi.length > 100
                        ? '${a.deskripsi.substring(0, 100)}...'
                        : a.deskripsi,
                    _searchQuery,
                  ),
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    Helpers.formatDate(a.tanggal),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  if (a.status.toLowerCase() == 'pending')
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Hapus',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit')
                          _showEditForm(a);
                        else if (value == 'delete') _confirmDelete(a);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Menampilkan detail aspirasi dalam bottom sheet
  void _showDetail(Aspirasi a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      a.judul,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  StatusBadge(
                    status: a.status,
                    showEditIcon: a.status.toLowerCase() == 'pending',
                    onEditPressed: () {
                      Navigator.pop(context);
                      _showEditForm(a);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _infoRow(
                Icons.calendar_today_rounded,
                Helpers.formatDate(a.tanggal),
              ),
              _infoRow(Icons.category_rounded, a.kategori),
              const SizedBox(height: 24),
              _section('Deskripsi', Icons.description_rounded, a.deskripsi),
              if (a.umpanBalik != null && a.umpanBalik!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _section(
                  'Umpan Balik Admin',
                  Icons.comment_rounded,
                  a.umpanBalik!,
                  color: AppColors.info,
                ),
              ],
              if (a.progres.isNotEmpty) ...[
                const SizedBox(height: 16),
                _section(
                  'Progres',
                  Icons.timeline_rounded,
                  a.progres,
                  color: AppColors.success,
                ),
              ],
              if (a.status.toLowerCase() == 'pending') ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditForm(a);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppColors.primary),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_rounded, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('Edit',
                                style: TextStyle(color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _confirmDelete(a);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_rounded, size: 20),
                            const SizedBox(width: 8),
                            const Text('Hapus'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _section(
    String title,
    IconData icon,
    String content, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (color ?? AppColors.textSecondary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (color ?? AppColors.textSecondary).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color ?? AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }
}

// Form Edit Aspirasi untuk Siswa
class _EditAspirasiForm extends StatefulWidget {
  final Aspirasi aspirasi;
  final VoidCallback onSaved;

  const _EditAspirasiForm({
    required this.aspirasi,
    required this.onSaved,
  });

  @override
  State<_EditAspirasiForm> createState() => _EditAspirasiFormState();
}

class _EditAspirasiFormState extends State<_EditAspirasiForm> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String? _selectedKategori;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _judulController.text = widget.aspirasi.judul;
    _deskripsiController.text = widget.aspirasi.deskripsi;
    _selectedKategori = widget.aspirasi.kategori;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final updated = widget.aspirasi.copyWith(
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        kategori: _selectedKategori!,
      );

      final success = await DataManager.editAspirasi(updated);

      if (success) {
        widget.onSaved();
      } else {
        if (mounted) {
          Helpers.showSnackBar(
            context,
            '❌ Gagal memperbarui aspirasi',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          '❌ Error: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Edit Aspirasi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${widget.aspirasi.status.toUpperCase()}',
                style: TextStyle(
                  color: Helpers.getStatusColor(widget.aspirasi.status, context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_rounded, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hanya bisa mengedit jika status masih PENDING',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
              ModernTextField(
                label: 'Judul',
                hint: 'Ringkasan masalah',
                icon: Icons.title_rounded,
                keyboardType: TextInputType.text,
                controller: _judulController,
                maxLength: 100,
                validator: (v) => v!.isEmpty
                    ? 'Judul harus diisi'
                    : v.length < 10
                        ? 'Minimal 10 karakter'
                        : null,
              ),
              const SizedBox(height: 20),
              ModernTextField(
                label: 'Deskripsi',
                hint: 'Jelaskan detail masalahnya',
                icon: Icons.description_rounded,
                keyboardType: TextInputType.multiline,
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
              GradientButton(
                text: 'Perbarui Aspirasi',
                icon: Icons.update_rounded,
                onPressed: _submit,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
