import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../app/data.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'aspirasi_pdf_export.dart';

// ============================================================================
// ADMIN SCREEN - KELOLA ASPIRASI DENGAN FITUR SEARCH
// ============================================================================
//
// ✅ FITUR BARU YANG DITAMBAHKAN:
// 1. Search bar untuk cari aspirasi (judul, nama siswa, deskripsi, kategori)
// 2. Highlight text yang match dengan query pencarian
// 3. Sort otomatis berdasarkan relevansi
// 4. Empty state khusus untuk hasil pencarian
// 5. Info hasil pencarian di header
//
// ✅ FITUR LAMA YANG TETAP ADA:
// - Filter tanggal, bulan, nama siswa, kategori
// - Hapus aspirasi dengan konfirmasi
// - Edit/umpan balik aspirasi
// - Refresh data
// - Logout
//
// CARA KERJA SEARCH:
// 1. User ketik di search bar
// 2. Sistem tunggu 500ms (debouncing)
// 3. Filter aspirasi berdasarkan query
// 4. Tampilkan hasil dengan highlight pada text yang match
// 5. Bisa dikombinasikan dengan filter lain
//
// ============================================================================

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  User? _currentUser;
  List<Aspirasi> _allAspirasi = [];
  List<Aspirasi> _filteredAspirasi = [];
  bool _isLoading = true;
  bool _showFilters = false;

  // ========================================
  // ✅ TAMBAH: Variabel untuk SEARCH
  // ========================================
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // Query pencarian

  // Filters (yang sudah ada)
  String? _filterTanggal;
  String? _filterBulan;
  String? _filterSiswa;
  String? _filterKategori;

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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await DataManager.getCurrentUser();
    final aspirasi = await DataManager.getAspirasi();
    setState(() {
      _currentUser = user;
      _allAspirasi = aspirasi..sort((a, b) => b.tanggal.compareTo(a.tanggal));
      _applyFilters();
      _isLoading = false;
    });
  }

  // ========================================
  // ✅ EDIT: Fungsi filter DENGAN SEARCH
  // ========================================
  void _applyFilters() {
    setState(() {
      _filteredAspirasi = _allAspirasi.where((a) {
        // 1. Logika Search (Pencarian)
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();

          // Cek apakah salah satu bidang mengandung query
          bool matchSearch = a.judul.toLowerCase().contains(query) ||
              a.nama.toLowerCase().contains(query) ||
              a.deskripsi.toLowerCase().contains(query) ||
              a.kategori.toLowerCase().contains(query);

          if (!matchSearch) return false; // Jika tidak ada yang cocok, buang
        }

        // 2. Logika Filter Tambahan (Dropdown/Tanggal)
        if (_filterTanggal != null &&
            a.tanggal.toIso8601String().split('T')[0] != _filterTanggal)
          return false;

        if (_filterBulan != null &&
            a.tanggal.toIso8601String().substring(0, 7) != _filterBulan)
          return false;

        if (_filterSiswa != null &&
            !a.nama.toLowerCase().contains(_filterSiswa!.toLowerCase()))
          return false;

        if (_filterKategori != null && a.kategori != _filterKategori)
          return false;

        return true; // Lolos semua sensor
      }).toList();

      // 3. Pengurutan (Sorting)
      if (_searchQuery.isNotEmpty) {
        // Jika sedang mencari, urutkan berdasarkan yang paling relevan (awalan judul)
        _filteredAspirasi.sort((a, b) {
          final query = _searchQuery.toLowerCase();
          bool aStarts = a.judul.toLowerCase().startsWith(query);
          bool bStarts = b.judul.toLowerCase().startsWith(query);

          if (aStarts && !bStarts) return -1;
          if (!aStarts && bStarts) return 1;
          return b.tanggal.compareTo(a.tanggal); // Sisanya urut tanggal terbaru
        });
      } else {
        // Jika tidak mencari, urutkan berdasarkan tanggal terbaru saja
        _filteredAspirasi.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      }
    });
  }

  // ✅ EDIT: Clear termasuk search
  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _filterTanggal = null;
      _filterBulan = null;
      _filterSiswa = null;
      _filterKategori = null;
      _applyFilters();
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

  Future<void> _confirmDelete(Aspirasi aspirasi) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Hapus'),
        content: Text(
            'Yakin ingin menghapus aspirasi "${aspirasi.judul}"? Tindakan ini tidak dapat dibatalkan.'),
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
      setState(() => _isLoading = true);
      final success = await DataManager.deleteAspirasi(aspirasi.id);

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          await _loadData();
          Helpers.showSnackBar(context, '✅ Aspirasi berhasil dihapus!');
        } else {
          Helpers.showSnackBar(context, '❌ Gagal menghapus aspirasi',
              isError: true);
        }
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar')),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await DataManager.logout();
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  // ========================================
  // ✅ TAMBAH: Method untuk generate report PDF
  // ========================================
  Future<void> _generateReport() async {
    if (_filteredAspirasi.isEmpty) {
      Helpers.showSnackBar(context, 'Tidak ada data untuk direport');
      return;
    }

    try {
      String filterInfo = '';
      if (_searchQuery.isNotEmpty) {
        filterInfo = 'Hasil Pencarian: "$_searchQuery"';
      } else if (_filterTanggal != null ||
          _filterBulan != null ||
          _filterSiswa != null ||
          _filterKategori != null) {
        final filters = <String>[];
        if (_filterTanggal != null) filters.add('Tanggal: $_filterTanggal');
        if (_filterBulan != null) filters.add('Bulan: $_filterBulan');
        if (_filterSiswa != null) filters.add('Siswa: $_filterSiswa');
        if (_filterKategori != null) filters.add('Kategori: $_filterKategori');
        filterInfo = 'Filter: ${filters.join(", ")}';
      } else {
        filterInfo = 'Semua Data Aspirasi';
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AspirasiPdfExportScreen(
            aspirasi: _filteredAspirasi,
            filterTitle: filterInfo,
          ),
        ),
      );
    } catch (e) {
      Helpers.showSnackBar(
        context,
        'Error: ${e.toString()}',
        isError: true,
      );
    }
  }

  // ========================================
  // ✅ TAMBAH: Widget Search Bar
  // ========================================
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          // Debouncing: tunggu 500ms
          Future.delayed(const Duration(milliseconds: 500), () {
            if (value == _searchController.text) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            }
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari judul, nama siswa, deskripsi...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _applyFilters();
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
    return Scaffold(
      appBar: ModernAppBar(
          title: 'Admin - ${AppConstants.appName}', onLogout: _logout),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: DynamicAppColors.primaryGradient(context),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${_currentUser?.nama ?? "Admin"} 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Administrator',
                  style: TextStyle(
                      fontSize: 14, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),

          // ✅ TAMBAH: Search Bar
          _buildSearchBar(),

          // Filter Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: ${_filteredAspirasi.length} aspirasi',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (_searchQuery.isNotEmpty)
                        Text(
                          'Hasil pencarian: "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_filterTanggal != null ||
                    _filterBulan != null ||
                    _filterSiswa != null ||
                    _filterKategori != null ||
                    _searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_all_rounded),
                    onPressed: _clearFilters,
                    tooltip: 'Clear Filters',
                  ),
                IconButton(
                  icon: Icon(_showFilters
                      ? Icons.filter_list_off_rounded
                      : Icons.filter_list_rounded),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  tooltip: 'Filter',
                ),
              ],
            ),
          ),

          // ✅ TAMBAH: Report Button Section - DI SINI TEMPAT YANG BENAR
          if (_filteredAspirasi.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _generateReport,
                icon: const Icon(Icons.picture_as_pdf, size: 20),
                label: const Text(
                  'Generate PDF Report',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),

          if (_showFilters) _buildFilterSection(),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAspirasi.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                _searchQuery.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.inbox_rounded,
                                size: 100,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Tidak ada hasil untuk "$_searchQuery"'
                                  : 'Tidak ada aspirasi',
                              style: TextStyle(
                                  fontSize: 16, color: AppColors.textSecondary),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _clearFilters,
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
                            // ✅ EDIT: Gunakan card dengan highlight
                            if (_searchQuery.isNotEmpty) {
                              return _buildCardWithHighlight(
                                  _filteredAspirasi[i]);
                            }
                            return AspirasiCard(
                              aspirasi: _filteredAspirasi[i],
                              showUser: true,
                              showMenu: true,
                              onTap: () =>
                                  _showUmpanBalik(_filteredAspirasi[i]),
                              onEdit: () =>
                                  _showUmpanBalik(_filteredAspirasi[i]),
                              onDelete: () =>
                                  _confirmDelete(_filteredAspirasi[i]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ✅ TAMBAH: Card dengan highlight
  Widget _buildCardWithHighlight(Aspirasi a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showUmpanBalik(a),
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
                  const Icon(Icons.person,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: _highlightText(a.nama, _searchQuery),
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
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
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit')
                        _showUmpanBalik(a);
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

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.filter_alt_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Filter Data',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Per Tanggal',
              prefixIcon: const Icon(Icons.calendar_today_rounded),
              suffixIcon: _filterTanggal != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                            _filterTanggal = null;
                            _applyFilters();
                          }))
                  : null,
            ),
            readOnly: true,
            controller: TextEditingController(text: _filterTanggal ?? ''),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _filterTanggal = date.toIso8601String().split('T')[0];
                  _applyFilters();
                });
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Per Bulan',
              prefixIcon: const Icon(Icons.calendar_month_rounded),
              suffixIcon: _filterBulan != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                            _filterBulan = null;
                            _applyFilters();
                          }))
                  : null,
            ),
            readOnly: true,
            controller: TextEditingController(text: _filterBulan ?? ''),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _filterBulan = date.toIso8601String().substring(0, 7);
                  _applyFilters();
                });
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Nama Siswa',
              prefixIcon: const Icon(Icons.person_search_rounded),
              suffixIcon: _filterSiswa != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                            _filterSiswa = null;
                            _applyFilters();
                          }))
                  : null,
            ),
            onChanged: (v) => setState(() {
              _filterSiswa = v.isEmpty ? null : v;
              _applyFilters();
            }),
            controller: TextEditingController(text: _filterSiswa ?? ''),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _filterKategori,
            decoration: const InputDecoration(
              labelText: 'Kategori',
              prefixIcon: Icon(Icons.category_rounded),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Semua')),
              ...AppConstants.kategoris
                  .map((k) => DropdownMenuItem(value: k, child: Text(k))),
            ],
            onChanged: (v) => setState(() {
              _filterKategori = v;
              _applyFilters();
            }),
          ),
        ],
      ),
    );
  }

  void _showUmpanBalik(Aspirasi aspirasi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _UmpanBalikForm(
        aspirasi: aspirasi,
        onSaved: () {
          _loadData();
          Navigator.pop(context);
          Helpers.showSnackBar(context, '✅ Umpan balik berhasil disimpan!');
        },
      ),
    );
  }
}

// Form Umpan Balik
class _UmpanBalikForm extends StatefulWidget {
  final Aspirasi aspirasi;
  final VoidCallback onSaved;

  const _UmpanBalikForm({required this.aspirasi, required this.onSaved});

  @override
  State<_UmpanBalikForm> createState() => _UmpanBalikFormState();
}

class _UmpanBalikFormState extends State<_UmpanBalikForm> {
  final _formKey = GlobalKey<FormState>();
  final _umpanBalikController = TextEditingController();
  final _progresController = TextEditingController();
  String? _selectedStatus;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _umpanBalikController.text = widget.aspirasi.umpanBalik ?? '';
    _progresController.text = widget.aspirasi.progres;
    _selectedStatus = widget.aspirasi.status;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    widget.aspirasi.status = _selectedStatus!;
    widget.aspirasi.umpanBalik = _umpanBalikController.text.trim();
    widget.aspirasi.progres = _progresController.text.trim();

    await DataManager.updateAspirasi(widget.aspirasi);

    setState(() => _isSubmitting = false);
    widget.onSaved();
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                'Umpan Balik Aspirasi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.aspirasi.judul,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _infoRow('Nama', widget.aspirasi.nama),
                    _infoRow('Kelas', widget.aspirasi.kelas),
                    _infoRow('Kategori', widget.aspirasi.kategori),
                    _infoRow(
                        'Tanggal', Helpers.formatDate(widget.aspirasi.tanggal)),
                    const SizedBox(height: 12),
                    Text(widget.aspirasi.deskripsi,
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.update_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('MENUNGGU')),
                  DropdownMenuItem(value: 'proses', child: Text('DIPROSES')),
                  DropdownMenuItem(value: 'selesai', child: Text('SELESAI')),
                  DropdownMenuItem(value: 'ditolak', child: Text('DITOLAK')),
                ],
                onChanged: (v) => setState(() => _selectedStatus = v),
                validator: (v) => v == null ? 'Pilih status' : null,
              ),
              const SizedBox(height: 20),
              ModernTextField(
                label: 'Umpan Balik',
                hint: 'Berikan tanggapan...',
                icon: Icons.comment_rounded,
                keyboardType: TextInputType.multiline,
                controller: _umpanBalikController,
                maxLines: 5,
                maxLength: 500,
                validator: (v) => v!.isEmpty
                    ? 'Harus diisi'
                    : v.length < 10
                        ? 'Min 10 karakter'
                        : null,
              ),
              const SizedBox(height: 20),
              ModernTextField(
                label: 'Progres',
                hint: 'Update progres perbaikan...',
                icon: Icons.timeline_rounded,
                keyboardType: TextInputType.multiline,
                controller: _progresController,
                maxLines: 3,
                maxLength: 300,
                validator: (v) => v!.isEmpty
                    ? 'Harus diisi'
                    : v.length < 10
                        ? 'Min 10 karakter'
                        : null,
              ),
              const SizedBox(height: 32),
              GradientButton(
                text: 'Simpan',
                icon: Icons.check_circle_rounded,
                onPressed: _submit,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
