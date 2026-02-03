import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../app/data.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

class SiswaScreen extends StatefulWidget {
  const SiswaScreen({super.key});

  @override
  State<SiswaScreen> createState() => _SiswaScreenState();
}

class _SiswaScreenState extends State<SiswaScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  User? _currentUser;
  late TabController _tabController;
  final GlobalKey<_HistoriTabState> historyKey = GlobalKey<_HistoriTabState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await DataManager.getCurrentUser();
    setState(() => _currentUser = user);
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
      appBar: ModernAppBar(title: AppConstants.appName, onLogout: _logout),
      body: Column(
        children: [
          // User Header dengan Gradient
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
                  'Halo, ${_currentUser?.nama ?? "Siswa"} 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser?.kelas ?? '',
                  style: TextStyle(
                      fontSize: 14, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              onTap: (index) => setState(() => _currentIndex = index),
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(
                    icon: Icon(Icons.add_circle_rounded),
                    text: 'Kirim Aspirasi'),
                Tab(icon: Icon(Icons.history_rounded), text: 'Histori'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _FormTab(
                    user: _currentUser,
                    onSubmitted: () {
                      historyKey.currentState?.refresh();
                      _tabController.animateTo(1);
                    }),
                _HistoriTab(key: historyKey, userId: _currentUser?.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Form Tab
class _FormTab extends StatefulWidget {
  final User? user;
  final VoidCallback? onSubmitted;
  const _FormTab({this.user, this.onSubmitted});

  @override
  State<_FormTab> createState() => _FormTabState();
}

class _FormTabState extends State<_FormTab> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String? _selectedKategori;
  bool _isSubmitting = false;

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
        progres: 'Menunggu review admin',
      );

      await DataManager.addAspirasi(aspirasi);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _selectedKategori = null;
          _judulController.clear();
          _deskripsiController.clear();
        });
        Helpers.showSnackBar(context, '✅ Aspirasi berhasil dikirim!');
        _formKey.currentState!.reset();
        widget.onSubmitted?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Helpers.showSnackBar(context, '❌ Gagal mengirim aspirasi: $e',
            isError: true);
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

// Histori Tab
class _HistoriTab extends StatefulWidget {
  final String? userId;
  const _HistoriTab({super.key, this.userId});

  @override
  State<_HistoriTab> createState() => _HistoriTabState();
}

class _HistoriTabState extends State<_HistoriTab> {
  List<Aspirasi> _aspirasi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final all = await DataManager.getAspirasi();
    if (!mounted) return;

    setState(() {
      _aspirasi = all
          .where((a) => a.userId == widget.userId)
          .toList()
        ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
      _isLoading = false;
    });
  }

  void refresh() => _loadData();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_aspirasi.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 100, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada aspirasi',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _aspirasi.length,
        itemBuilder: (context, i) => AspirasiCard(
          aspirasi: _aspirasi[i],
          onTap: () => _showDetail(_aspirasi[i]),
        ),
      ),
    );
  }

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
                    status: a.progres ?? 'Menunggu',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _infoRow(
                  Icons.calendar_today_rounded, Helpers.formatDate(a.tanggal)),
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
              if (a.progres != null && a.progres!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _section(
                  'Progres',
                  Icons.timeline_rounded,
                  a.progres!,
                  color: AppColors.success,
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

  Widget _section(String title, IconData icon, String content, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (color ?? AppColors.textSecondary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: (color ?? AppColors.textSecondary).withOpacity(0.3)),
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
