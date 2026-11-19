import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/dio_client.dart';
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Username'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Username Baru',
              hintText: '4-30 karakter (huruf, angka, titik, _)',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Username wajib diisi';
              if (!RegExp(r'^[a-zA-Z0-9._]{4,30}$').hasMatch(v.trim())) {
                return '4-30 karakter: huruf, angka, titik, atau garis bawah';
              }
              return null;
            },
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
                } catch (_) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Gagal mengubah username.')),
                    );
                  }
                  return;
                }
              }
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Username berhasil diubah menjadi $newUsername.'),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Password'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  validator: (v) {
                    if (v == null || v.length < 8) {
                      return 'Minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Password Baru',
                  ),
                  validator: (v) {
                    if (v != newCtrl.text) {
                      return 'Konfirmasi password tidak cocok';
                    }
                    return null;
                  },
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
                } catch (_) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Gagal mengganti password.')),
                    );
                  }
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Wajib Pajak',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user?.username ?? "-"}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Divider(height: 24),
                  _AccountInfoRow('NIK', AppValidators.maskNik(user?.nik)),
                  const SizedBox(height: 10),
                  _AccountInfoRow(
                    'NPWP',
                    user?.npwp?.isNotEmpty == true ? user!.npwp! : '-',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.alternate_email),
                  title: const Text('Ubah Username'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangeUsernameDialog(context, ref),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Ganti Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context, ref),
                ),
                const Divider(),
                SwitchListTile(
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  title: const Text('Mode Gelap'),
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
              foregroundColor: const Color(0xFFB91C1C),
              side: const BorderSide(color: Color(0xFFB91C1C)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Keluar'),
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
                        style: TextStyle(color: Color(0xFFB91C1C)),
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

class _AccountInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _AccountInfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
