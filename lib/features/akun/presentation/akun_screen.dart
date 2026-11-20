import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../core/utils/validators.dart';
import '../../auth/presentation/auth_notifier.dart';

class AkunScreen extends ConsumerWidget {
  const AkunScreen({super.key});

  void _showChangeUsernameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(authProvider).user?.username ?? '',
    );
    final formKey = GlobalKey<FormState>();
    String? serverError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Ubah Username'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Username Baru',
                    hintText: '4-30 karakter (huruf, angka, titik, _)',
                    errorText: serverError,
                  ),
                  onChanged: (_) {
                    if (serverError != null) {
                      setDialogState(() => serverError = null);
                    }
                  },
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Username wajib diisi';
                    if (!RegExp(r'^[a-zA-Z0-9._]{4,30}$').hasMatch(v.trim())) {
                      return '4-30 karakter: huruf, angka, titik, atau garis bawah';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final newUsername = controller.text.trim();
                if (!AppConfig.useMockData) {
                  try {
                    await ref
                        .read(dioProvider)
                        .patch('/me/username', data: {'username': newUsername});
                  } catch (e) {
                    setDialogState(() {
                      serverError = 'Username sudah digunakan atau tidak valid.';
                    });
                    return;
                  }
                }
                ref.read(authProvider.notifier).updateUsernameLocal(newUsername);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Username berhasil diubah menjadi $newUsername.'),
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? serverError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Ganti Password'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (serverError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: Color(0xFFB91C1C)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              serverError!,
                              style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  TextFormField(
                    controller: oldCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password Lama'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password Baru (min. 8 karakter)',
                    ),
                    validator: (v) =>
                        (v == null || v.length < 8) ? 'Minimal 8 karakter' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                    ),
                    validator: (v) =>
                        v != newCtrl.text ? 'Konfirmasi password tidak cocok' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                if (!AppConfig.useMockData) {
                  try {
                    await ref.read(dioProvider).put('/me/password', data: {
                      'password_lama': oldCtrl.text,
                      'password_baru': newCtrl.text,
                      'password_baru_confirmation': confirmCtrl.text,
                    });
                  } catch (e) {
                    setDialogState(() {
                      serverError = 'Password lama salah atau terjadi kesalahan.';
                    });
                    return;
                  }
                }
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password berhasil diperbarui.')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Akun')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Wajib Pajak',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${user?.username ?? "-"}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDeep,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _ProfileIdentityRow('NIK', AppValidators.maskNik(user?.nik)),
                      const SizedBox(height: 8),
                      _ProfileIdentityRow(
                        'NPWP',
                        user?.npwp?.isNotEmpty == true ? user!.npwp! : '-',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Keamanan & Preferensi',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.alternate_email_rounded),
                  title: const Text(
                    'Ubah Username',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showChangeUsernameDialog(context, ref),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded),
                  title: const Text(
                    'Ganti Password',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showChangePasswordDialog(context, ref),
                ),
                const Divider(),
                SwitchListTile(
                  secondary: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  ),
                  title: const Text(
                    'Mode Gelap',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text('Disimpan lokal di perangkat ini'),
                  value: isDark,
                  onChanged: (val) =>
                      ref.read(themeModeProvider.notifier).toggleTheme(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.statusRejectedText,
              side: const BorderSide(color: AppTheme.statusRejectedText),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Keluar dari Akun'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Keluar dari Akun'),
                  content: const Text(
                    'Sesi login pada perangkat ini akan dihapus. Lanjutkan?',
                  ),
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
                        style: TextStyle(color: AppTheme.statusRejectedText),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileIdentityRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileIdentityRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
