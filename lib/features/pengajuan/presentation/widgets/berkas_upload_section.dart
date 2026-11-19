import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/pengajuan_models.dart';

class BerkasUploadSection extends StatelessWidget {
  final List<BerkasRequirement> requirements;
  final Map<String, UploadedBerkas> uploadedFiles;
  final Map<String, String> existingFiles;
  final void Function(String key, UploadedBerkas file) onFilePicked;
  final void Function(String key) onFileRemoved;
  final Map<String, List<String>>? serverErrors;

  const BerkasUploadSection({
    super.key,
    required this.requirements,
    required this.uploadedFiles,
    this.existingFiles = const {},
    required this.onFilePicked,
    required this.onFileRemoved,
    this.serverErrors,
  });

  static const int maxBytes = 1024 * 1024; // 1 MB

  Future<void> _pickSource(BuildContext context, BerkasRequirement req) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil Foto dari Kamera'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih Gambar dari Galeri'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Pilih File PDF (Maks. 1 MB)'),
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
          ],
        ),
      ),
    );

    if (choice == null || !context.mounted) return;

    if (choice == 'camera' || choice == 'gallery') {
      await _pickImage(
        context,
        req,
        choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
      );
    } else if (choice == 'pdf') {
      await _pickPdf(context, req);
    }
  }

  Future<void> _pickImage(
    BuildContext context,
    BerkasRequirement req,
    ImageSource source,
  ) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (picked == null) return;

      var file = File(picked.path);
      var bytes = await file.length();

      if (bytes > maxBytes && !kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        for (final quality in [75, 55, 35, 20]) {
          final targetPath =
              '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final result = await FlutterImageCompress.compressAndGetFile(
            file.path,
            targetPath,
            quality: quality,
            minWidth: 1280,
            minHeight: 1280,
          );
          if (result != null) {
            file = File(result.path);
            bytes = await file.length();
            if (bytes <= maxBytes) break;
          }
        }
      }

      if (bytes > maxBytes) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Ukuran gambar masih melebihi 1 MB setelah kompresi. Pilih gambar lain.',
              ),
            ),
          );
        }
        return;
      }

      onFilePicked(
        req.key,
        UploadedBerkas(
          path: file.path,
          fileName: picked.name,
          isPdf: false,
          sizeBytes: bytes,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengambil gambar dari perangkat.'),
          ),
        );
      }
    }
  }

  Future<void> _pickPdf(BuildContext context, BerkasRequirement req) async {
    try {
      final res = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (res.isEmpty) return;

      final picked = res.first;
      final filePath = picked.path;
      if (filePath == null) return;

      final size = await File(filePath).length();
      final isPdf = (picked.extension ?? '').toLowerCase() == 'pdf';

      if (size > maxBytes) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ukuran file maksimal 1 MB')),
          );
        }
        return;
      }

      onFilePicked(
        req.key,
        UploadedBerkas(
          path: picked.path!,
          fileName: picked.name,
          isPdf: isPdf,
          sizeBytes: size,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memilih berkas.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Format: JPG, PNG, atau PDF. Maksimal 1 MB per berkas. Pastikan gambar jelas dan tidak terbalik.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        ...requirements.map((req) {
          final uploaded = uploadedFiles[req.key];
          final existingName = existingFiles[req.key];
          final err = serverErrors?[req.key]?.first;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            req.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: req.wajib
                                ? const Color(0xFFFEE2E2)
                                : Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            req.wajib ? 'Wajib' : 'Opsional',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: req.wajib
                                  ? const Color(0xFFB91C1C)
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (uploaded != null)
                      Row(
                        children: [
                          if (!uploaded.isPdf && File(uploaded.path).existsSync())
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                File(uploaded.path),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            const Icon(
                              Icons.picture_as_pdf,
                              size: 36,
                              color: Color(0xFFB91C1C),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  uploaded.fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  uploaded.sizeLabel,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Ganti berkas',
                            onPressed: () => _pickSource(context, req),
                            icon: const Icon(Icons.edit_outlined, size: 20),
                          ),
                          IconButton(
                            tooltip: 'Hapus berkas',
                            onPressed: () => onFileRemoved(req.key),
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      )
                    else if (existingName != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_file,
                            size: 20,
                            color: Color(0xFF15803D),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Berkas tersimpan: $existingName',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _pickSource(context, req),
                            child: const Text('Ganti'),
                          ),
                        ],
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () => _pickSource(context, req),
                        icon: const Icon(Icons.upload_file_outlined, size: 18),
                        label: const Text('Unggah Berkas'),
                      ),
                    if (err != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        err,
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
