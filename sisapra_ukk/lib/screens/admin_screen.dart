import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../app/data.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

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

  // Filters
  String? _filterTanggal;
  String? _filterBulan;
  String? _filterSiswa;
  String? _filterKategori;

  @override
  void initState() {
    super.initState();
    _loadData();
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

  void _applyFilters() {
    _filteredAspirasi = _allAspirasi.where((a) {
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
      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _filterTanggal = null;
      _filterBulan = null;
      _filterSiswa = null;
      _filterKategori = null;
      _applyFilters();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
          title: 'Admin - ${AppConstants.appName}', onLogout: _logout),
      body: Column(
        children: [
          // Admin Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
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

          // Filter Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total: ${_filteredAspirasi.length} aspirasi',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (_filterTanggal != null ||
                    _filterBulan != null ||
                    _filterSiswa != null ||
                    _filterKategori != null)
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

          // Filters Section
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
                            Icon(Icons.inbox_rounded,
                                size: 100, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('Tidak ada aspirasi',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _filteredAspirasi.length,
                          itemBuilder: (context, i) => AspirasiCard(
                            aspirasi: _filteredAspirasi[i],
                            showUser: true,
                            onTap: () => _showUmpanBalik(_filteredAspirasi[i]),
                          ),
                        ),
                      ),
          ),
        ],
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

          // Tanggal
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

          // Bulan
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

          // Nama Siswa
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

          // Kategori
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

              // Detail Aspirasi
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

              // Status
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

              // Umpan Balik
              ModernTextField(
                label: 'Umpan Balik',
                hint: 'Berikan tanggapan...',
                icon: Icons.comment_rounded,
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

              // Progres
              ModernTextField(
                label: 'Progres',
                hint: 'Update progres perbaikan...',
                icon: Icons.timeline_rounded,
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
