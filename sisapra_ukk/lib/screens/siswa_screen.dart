import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../app/data.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'siswa_form_tab.dart';
import 'siswa_histori_tab.dart';

class SiswaScreen extends StatefulWidget {
  final User user;

  const SiswaScreen({
    super.key,
    required this.user,
  });

  @override
  State<SiswaScreen> createState() => _SiswaScreenState();
}

class _SiswaScreenState extends State<SiswaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final GlobalKey<SiswaHistoriTabState> historyKey =
      GlobalKey<SiswaHistoriTabState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await DataManager.logout();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _onAspirasiSubmitted() {
    _tabController.animateTo(1);

    Future.delayed(const Duration(milliseconds: 300), () {
      historyKey.currentState?.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: ModernAppBar(
        title: 'Halo ${user.nama}',
        onLogout: _logout,
      ),
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: DynamicAppColors.primaryGradient(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${user.nama} 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.kelas ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // TAB BAR
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(icon: Icon(Icons.add_circle), text: 'Kirim Aspirasi'),
              Tab(icon: Icon(Icons.history), text: 'Histori'),
            ],
          ),

          // TAB VIEW
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SiswaFormTab(
                  user: user,
                  onSubmitted: _onAspirasiSubmitted,
                ),
                SiswaHistoriTab(
                  key: historyKey,
                  userId: user.id,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
