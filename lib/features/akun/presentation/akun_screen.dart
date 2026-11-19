import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../core/utils/validators.dart';
import '../../auth/presentation/auth_notifier.dart';

class AkunScreen extends ConsumerWidget {
  const AkunScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Akun'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card Profil Info
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFF006C4C),
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Wajib Pajak',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user?.username ?? "-"}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const Divider(height: 28),
                    _buildProfileRow(
                      icon: Icons.badge_outlined,
                      label: 'NIK (Disamarkan)',
                      value: AppValidators.maskNik(user?.nik),
                    ),
                    const SizedBox(height: 12),
                    _buildProfileRow(
                      icon: Icons.receipt_outlined,
                      label: 'NPWP',
                      value: user?.npwp?.isNotEmpty == true ? user!.npwp! : '-',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Pengaturan
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Mode Gelap'),
                    subtitle: const Text('Berlaku seketika di perangkat ini'),
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: const Color(0xFF006C4C),
                    ),
                    value: isDark,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).toggleTheme(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Logout
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar dari Akun'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Konfirmasi Keluar'),
                    content: const Text(
                        'Apakah Anda yakin ingin keluar dari aplikasi? Sesi token Anda akan dihapus.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref.read(authProvider.notifier).logout();
                        },
                        child: const Text(
                          'Keluar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
